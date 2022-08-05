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
let filter_null_result = compose not (String.equal "\"null\"")
let is_feat_query = contains ~sub:"FEATS_WITH"

let clean_batch_merge commands =
  commands
  
  |> uniq_string_list
  |> List.partition (compose not is_feat_query)
  |> join_partitions

let prepare_queries sort queries =
  queries
  |> List.map (Str.split (Str.regexp "\n"))
  |> List.flatten
  |> List.map String.trim
  |> List.filter (fun s -> String.length s > 6)
  |> run_if sort clean_batch_merge
  |> String.concat "\n"

let format_n4j_command =
  Printf.sprintf
    "./backend/neo4j-caller -p=\"%s\" --uri=%s -user=%s -statement=\"%s\" 2>&1"

exception DbConnectionFailed

let run_cypher_queries_cmd ?(sort = false) queries =
  let statements = prepare_queries sort queries in
  if String.length statements < 4 then Lwt.return ""
  else
    let%lwt command_result =
      Utils.run (format_n4j_command neo4j_password uri neo4j_user statements)
    in
    match command_result with
    | Ok results ->
        if Utils.contains ~sub:"Connection refused" results then
          Lwt.fail DbConnectionFailed
        else
          results
          |> trace "command results: %s."
          |> utf_decimal_decode
          |> Str.split (Str.regexp "\n")
          |> List.filter_map (fun result ->
                 if String.equal result "\"null\"" then None
                 else Some (result |> remove_hd_and_last |> replace "\\\"" "\""))
          |> String.concat ""
          |> Lwt.return
    | Error e ->
        Dream.log "Ooops: %s" (Printexc.to_string e);
        Lwt.fail e
module CypherShell = struct
  let format_n4j_command =
    Printf.sprintf
      "$JAVA_HOME/bin/java -jar ./backend/cypher-shell.jar -d featsOfDistance \
        --format plain -p \"%s\" -a %s -u %s \"%s\" 2>&1"
  
  exception DbConnectionFailed
  
  let run_cypher_queries_cmd ?(sort = false) queries =
    let statements = prepare_queries sort queries in
    if String.length statements < 4 then Lwt.return ""
    else
      let%lwt command_result =
        Utils.run (format_n4j_command neo4j_password uri neo4j_user statements)
      in
      match command_result with
      | Ok results ->
          if Utils.contains ~sub:"Connection refused" results then
            Lwt.fail DbConnectionFailed
          else
            results
            |> utf_decimal_decode
            |> trace "command results: %s."
            |> Str.split (Str.regexp "\n")
            |> List.filter_map (fun result ->
                    if String.equal result "\"null\"" then None
                    else Some (result |> remove_hd_and_last |> replace "\\\"" "\""))
            |> Utils.ListUtils.tail
            |> concat_json_strings
            |> Lwt.return
      | Error e ->
          Dream.log "Ooops: %s" (Printexc.to_string e);
          Lwt.fail e
end
let run_cypher_query cy = run_cypher_queries_cmd [ cy ]
let get_json_response_from_reply r = Some r
