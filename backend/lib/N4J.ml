type statement = { statement : string } [@@deriving yojson]
type n4j_payload = { statements : statement list } [@@deriving yojson]

open Utils
open Core.Fn
open Lwt.Syntax

let build_n4j_payload statements =
  { statements = statements |> List.map (fun stmt -> { statement = stmt }) }

let neo4j_password = get_env_var "N4J_PASSWORD" ~default:""
let neo4j_user = get_env_var "N4J_USER" ~default:"neo4j"

open Cohttp
open Lwt.Infix

let url =
  get_env_var "N4J_URL"
    ~default:"http://localhost:7474/db/data/transaction/commit"
  |> Uri.of_string

let uri = get_env_var "N4J_URI" ~default:"http://localhost:7474"

(* let run_cypher_queries cy =
   (* Dream.log "running:\n%s" (cy |> String.concat " "); *)
   let headers =
     Header.add_list (Header.init ())
       [
         ("Content-Type", "application/json");
         ("Authorization", "Basic " ^ neo4j_password);
       ]
   in
   let body =
     build_n4j_payload cy
     |> yojson_of_n4j_payload
     |> Yojson.Safe.to_string
     |> Cohttp_lwt.Body.of_string
   in

   Cohttp_lwt_unix.Client.post ~body ~headers url
   >>= Http.string_of_body
   >|= utf_decimal_decode
   >|= fun body ->
   Utils.log ("response: " ^ body) body |> ignore;
   body *)
let filter_null_result = compose not (String.equal "\"null\"")

(* module ListSet = Set.Make(List) *)
let wrap_yojson_safely of_yojson yojson =
  try of_yojson yojson
  with Ppx_yojson_conv_lib__Yojson_conv.Of_yojson_error (e, yo) ->
    raise (Utils.ParseError (Utils.print_yojson_exn (e, yo)))

let is_feat_query = contains "FEATS_WITH"

let clean_batch_merge commands =
  commands
  |> uniq_string_list
  |> List.partition (compose not is_feat_query)
  |> join_partitions

let run_cypher_queries_cmd ?(sort = false) queries =
  let statements =
    queries
    |> List.map (Str.split (Str.regexp "\n"))
    |> List.flatten
    |> List.map String.trim
    |> List.filter (fun s -> String.length s > 6)
    |> run_if sort clean_batch_merge
    |> String.concat "\n"
  in

  (* let* java_path = Utils.run {|whereis java | awk -F" " '{ print $2 }'|} in
   *)
  Utils.run
    (Printf.sprintf
       "$JAVA_HOME/bin/java -jar ./cypher-shell.jar --format plain -p \"%s\" \
        -a %s -u %s \"%s\""
       neo4j_password uri neo4j_user statements)
  >|= trace "command result: %s"
  >|= Str.split (Str.regexp "\n")
  >|= List.filter_map (fun result ->
          if String.equal result "\"null\"" then None
          else Some (result |> remove_hd_and_last |> replace "\\\"" "\""))
  >|= Utils.List.tail
  >|= concat_json_strings

let run_cypher_query cy = run_cypher_queries_cmd [ cy ]
let get_json_response_from_reply r = Some r
