open Models

module Queries = struct
  open Printf

  let create_album (album : album) =
    sprintf "CREATE (:Album {name: '%s', id: '%s', img: '%s' year: '%d'})"
      album.name album.id album.cover_art_url album.year

  let create_artist artist =
    sprintf "CREATE (:Author {name: '%s', id: '%s', img: '%s'})" artist.name
      artist.id artist.img

  (* let create_author_with_albums albums artist = 
     *)
  let create_song = sprintf "CREATE (:Song {name: '%s', id: '%s'})"
end

module Redis = struct
  open Redis_lwt
  open! Lwt.Syntax

  let graph_db_name = "featsOfDistance"
  let conn = Client.connect { host = "localhost"; port = 6379 } |> Lwt_main.run
  let run = Client.send_request conn

  let run_cypher_query cy =
    Printf.printf "running %s\n\n" cy;
    run [ "GRAPH.QUERY"; graph_db_name; cy ]

  let reset_db_query = {|MATCH (n) DETACH DELETE n|}
  let reset () = run_cypher_query reset_db_query

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
