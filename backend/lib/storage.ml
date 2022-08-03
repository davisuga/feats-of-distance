open Models
open! Utils
open Lwt.Infix

module Queries = struct
  open Printf

  let require_uniqueness =
    "CREATE CONSTRAINT uri_uniqueness FOR (a:Author) REQUIRE a.uri IS UNIQUE"

  (* let mark_author_as_saved artist_uri =  *)
  module Read = struct
    let create_shortest_path_song_nodes uri_a uri_b =
      sprintf
        {|MATCH (a1:Author {uri:'%s'}),
        (a2:Author {uri:'%s'})
         RETURN toJSON(nodes(shortestPath((a1)-[:FEATURES_IN|:HAS_FEATURE*1..100]->(a2))))|}
        uri_a uri_b

    let create_shortest_path ?(limit = 2) uri_a uri_b =
      sprintf
        {|MATCH (a1:Author {uri:'%s'}),
            (a2:Author {uri:'%s'})
             RETURN apoc.convert.toJson(shortestPath((a1)-[:FEATS_WITH*1..100]-(a2)))
             LIMIT %d|}
        uri_a uri_b limit

    let reset_db_query = {|MATCH (n) DETACH DELETE n|}

    let get_artist_by_uri =
      sprintf "MATCH (a:Author {uri: '%s'}) return apoc.convert.toJson(a)"

    let get_saved_artists = sprintf "MATCH (a:Author {saved:true}) return a.uri"
  end

  include Read

  let mark_artist_as_saved =
    sprintf "match (a:Author {uri: '%s'}) set a.saved = true"

  (* let create_artist artist =
     sprintf
       {|MERGE (a:Author { uri: '%s'}) set a.name = \"%s\" set  a.img = '%s'|}
       artist.name artist.uri
       (Option.value ~default:"" artist.img) *)

  (* let create_author_with_albums albums artist = 
     *)
  let clean_spotify_uri = Str.global_replace (Str.regexp ":") ""

  let make_author_merging (name, uri) =
    let clean_uri = clean_spotify_uri uri in
    sprintf
      {|MERGE (%s:Author {uri: '%s'}) set %s.name = \"%s\"
    |}
      clean_uri uri clean_uri
      (name |> String.escaped |> String.escaped)

  let map_snd f (a, b) = (a, f b)
  let snd (_, b) = b

  let create_feat_between_artists (song : song) artist_a_uri artist_b_uri =
    if artist_a_uri = artist_b_uri then ""
    else
      sprintf {|MERGE (%s)-[:FEATS_WITH {name:\"%s\", uri:'%s'}]->(%s)|}
        artist_a_uri
        (song.name |> String.escaped |> String.escaped)
        song.uri artist_b_uri

  let seq_to_list (seq : 'a Seq.t) =
    Seq.fold_left (fun acc seq_elem -> List.append acc [ seq_elem ]) [] seq

  let make_authors_features authors (song : song) =
    match authors with
    | hd :: tail ->
        tail
        |> List.map (create_feat_between_artists song hd)
        |> String.concat "\n"
    | _ -> ""

  let rec make_authors_features_for_all authors (song : song) =
    match authors with
    | head :: tail ->
        make_authors_features (head :: tail) song
        :: make_authors_features_for_all tail song
    | _ -> [ "" ]

  let create_song (song : song) =
    let song_authors = song.authors |> List.map (map_snd clean_spotify_uri) in
    let song_authors_uris = song_authors |> List.map snd in
    sprintf "%s\n%s"
      (song.authors |> List.map make_author_merging |> String.concat "\n")
      (song
      |> make_authors_features_for_all song_authors_uris
      |> String.concat "\n")

  let create_song_with_song_nodes (song : song) =
    let song_authors = song.authors |> List.map (map_snd clean_spotify_uri) in
    sprintf
      {|%s
    MERGE (song:Song {name: "%s", uri: "%s"})
    %s|}
      (song.authors |> List.map make_author_merging |> String.concat "\n")
      (String.escaped song.name) song.uri
      (song_authors
      |> List.map snd
      |> List.map (fun uri ->
             sprintf "MERGE (%s)-[:FEATURES_IN]->(song)-[:HAS_FEATURE]->(%s)"
               uri uri)
      |> String.concat "\n")
end

module Redis = struct
  open Redis_lwt

  let get_json_response_from_reply (rply : Redis_lwt.Client.reply) =
    match rply with
    | `Multibulk [ _; `Multibulk [ `Multibulk [ `Bulk str ] ]; _ ] -> str
    | _ -> None

  let redis_host =
    Sys.getenv_opt "REDIS_HOST" |> Option.value ~default:"localhost"

  let redis_port =
    Sys.getenv_opt "REDIS_PORT"
    |> Option.map int_of_string_opt
    |> Option.join
    |> Option.value ~default:6379

  let conn =
    let%lwt unauth_conn =
      Client.connect { host = redis_host; port = redis_port }
    in
    match Sys.getenv_opt "REDIS_PASSWORD" with
    | Some pwd ->
        let%lwt _ = Client.auth unauth_conn pwd in
        Lwt.return unauth_conn
    | None -> Lwt.return unauth_conn

  let ( let* ) = Lwt.bind
  let graph_db_name = "featsOfDistance"

  let run args =
    let* conn = conn in
    Client.send_custom_request conn args

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

  let string_of_reply_reply_list
      (rrl : Redis_lwt.Client.reply list list Lwt.t option) =
    match rrl with
    | Some promise ->
        promise >|= fun r -> List.flatten r |> List.map json_of_reply
    | None -> Lwt.return [ `Null ]
end
