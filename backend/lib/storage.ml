open Models

module Queries = struct
  open Printf

  let create_shortest_path id_a id_b =
    sprintf
      {|MATCH (a1:Author {id:'%s'}),
      (a2:Author {id:'%s'})
       RETURN toJSON(nodes(shortestPath((a1)-[:FEATURES_IN|:HAS_FEATURE*1..100]->(a2))))|}
      id_a id_b

  let create_multiget ids =
    sprintf "%s"
      (ids |> List.map (sprintf {|(a {id: '%s'}),|}) |> String.concat "\n")

  let capture_ids_from_path_query =
    Re2.find_all_exn (Re2.create_exn {|\([0-9]+\)|})

  let get_json_response_from_reply (rply : Redis_lwt.Client.reply) =
    match rply with
    | `Multibulk [ _; `Multibulk [ `Multibulk [ `Bulk str ] ]; _ ] -> str
    | _ -> None

  let create_album (album : album) =
    sprintf {|CREATE (:Album {name: "%s", id: "%s", img: "%s" year: "%d"})|}
      album.name album.id album.cover_art_url album.year

  let create_artist artist =
    sprintf {|MERGE (:Author {name: "%s", id: "%s", img: "%s"})|} artist.name
      artist.id
      (Option.value ~default:"" artist.img)

  (* let create_author_with_albums albums artist = 
     *)
  let clean_spotify_uri = Str.global_replace (Str.regexp ":") ""

  let make_author_merging (name, id) =
    sprintf
      {|MERGE (%s:Author {id: '%s', name: "%s"})
    |}
      (clean_spotify_uri id) id (String.escaped name)

  let map_snd f (a, b) = (a, f b)
  let snd (_, b) = b

  let seq_to_list (seq : 'a Seq.t) =
    Seq.fold_left (fun acc seq_elem -> List.append acc [ seq_elem ]) [] seq

  let create_song (song : song) =
    let song_authors = song.authors |> List.map (map_snd clean_spotify_uri) in

    sprintf
      {|%s
    MERGE (song:Song {name: "%s", id: "%s"})
    %s|}
      (song.authors |> List.map make_author_merging |> String.concat "\n")
      (String.escaped song.name) song.id
      (song_authors
      |> List.map snd
      |> List.map (fun uri ->
             sprintf "MERGE (%s)-[:FEATURES_IN]->(song)-[:HAS_FEATURE]->(%s)"
               uri uri)
      |> String.concat "\n")

  let reset_db_query = {|MATCH (n) DETACH DELETE n|}
end

module Redis = struct
  open Redis_lwt

  let ( let* ) = Lwt.bind
  let graph_db_name = "featsOfDistance"
  let conn = Client.connect { host = "localhost"; port = 6379 }

  let run args =
    let* conn = conn in
    Client.send_request conn args

  let run_cypher_query cy = run [ "GRAPH.QUERY"; graph_db_name; cy ]
  let reset () = run_cypher_query Queries.reset_db_query

  let rec string_of_reply : Client.reply -> string = function
    | `Status s -> Printf.sprintf "(Status %s)" s
    | `Moved { slot; host; port } ->
        Printf.sprintf "MOVED %d %s:%i" slot host port
    | `Ask { slot; host; port } -> Printf.sprintf "ASK %d %s:%i" slot host port
    | `Error s -> Printf.sprintf "(Error %s)" s
    | `Int i -> Printf.sprintf "(Int %i)" i
    | `Int64 i -> Printf.sprintf "(Int64 %Li)" i
    | `Bulk None -> "(Bulk None)"
    | `Bulk (Some s) -> Printf.sprintf "(Bulk (Some %s))" s
    | `Multibulk replies ->
        let x = List.map string_of_reply replies |> String.concat "; " in
        Printf.sprintf "Multibulk [ %s; ]" x

  let rec json_of_reply : Redis_lwt.Client.reply -> Yojson.Safe.t = function
    | `Status s -> `String s
    | `Moved { slot; host; port } ->
        `Assoc
          [
            ( "moved",
              `Assoc
                [
                  ("slot", `Int slot);
                  ("host", `String host);
                  ("port", `Int port);
                ] );
          ]
    | `Ask { slot; host; port } ->
        `Assoc
          [
            ( "ask",
              `Assoc
                [
                  ("slot", `Int slot);
                  ("host", `String host);
                  ("port", `Int port);
                ] );
          ]
    | `Error s -> `Assoc [ ("error", `String s) ]
    | `Int i -> `Int i
    | `Int64 i -> `Int (i |> Int64.to_int)
    | `Bulk None -> `Null
    | `Bulk (Some s) -> `String s
    (* | `Multibulk [`Multibulk [`Bulk (Some key) ; replyv]] -> `Assoc [key, json_of_reply replyv] *)
    | `Multibulk [ `Multibulk properties ] ->
        `List (properties |> List.map json_of_reply)
    | `Multibulk replies -> `List (replies |> List.map json_of_reply)
end

module N4J = struct
  type statement = { statement : string } [@@deriving yojson]
  type n4j_payload = { statements : statement list } [@@deriving yojson]

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

    Cohttp_lwt_unix.Client.post ~body ~headers url >>= Http.string_of_body
    >|= fun body ->
    Utils.log ("response: " ^ body) body |> ignore;
    body

  let run_cypher_query cy = run_cypher_queries [ cy ]

  let get_json_response_from_reply r =
    Dream.log "%s" r;
    Some r
end
