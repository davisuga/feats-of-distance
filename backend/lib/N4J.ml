type statement = { statement : string } [@@deriving yojson]
type n4j_payload = { statements : statement list } [@@deriving yojson]

open Utils

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

let run_cypher_queries cy =
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
  body

let run_cypher_query cy = run_cypher_queries [ cy ]
let get_json_response_from_reply r = Some r