open Models
open Utils

let artist =
  Graphql_lwt.Schema.(
    obj "artist" ~fields:(fun _info ->
        [
          field "uri" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info artist -> artist.id);
          field "name" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info artist -> artist.name);
          field "img" ~typ:string
            ~args:Arg.[]
            ~resolve:(fun _info artist -> artist.img);
        ]))

open! Lwt.Infix

let schema =
  Graphql_lwt.Schema.(
    schema
      [
        io_field "artists"
          ~typ:(non_null (list (non_null artist)))
          ~args:Arg.[ arg "search_term" ~typ:string ]
          ~resolve:(fun _info () search_term ->
            match search_term with
            | Some term ->
                Http.search_artists term (* >|= Models.artist_of_yojson *)
                >|= Array.to_list
                >|= Result.ok
            | None -> Lwt.return (Result.Error "Empty search term"));
      ])

open Lwt.Syntax

let cors_middleware inner_handler req =
  let new_headers =
    [
      ("Allow", "OPTIONS, GET, HEAD, POST");
      ("Access-Control-Allow-Origin", "*");
      ("Access-Control-Allow-Headers", "*");
    ]
  in
  let+ response = inner_handler req in

  new_headers
  |> List.map (fun (key, value) -> Dream.add_header response key value)
  |> ignore;

  response

(* let default_query = "{\\n  artists {\\n    name\\n    id\\n  }\\n}\\n" *)
(* content-type,Accept-Encoding,Accept-Language,Access-Control-Request-Headers,Access-Control-Request-Method,Connection,Host,Origin,Referer,Sec-Fetch-Mode,User-Agent,Content-Type *)
let start port =
  Dream.run ~port ~interface:"0.0.0.0" ~adjust_terminal:false
  @@ Dream.logger
  @@ cors_middleware
  @@ Dream.router
       [
         Dream.post "/graphql" (Dream.graphql Lwt.return schema);
         Dream.options "/graphql" (fun _req ->
             Dream.respond ~headers:[ ("Allow", "OPTIONS, GET, HEAD, POST") ] "");
         Dream.get "/" (Dream.graphiql "/graphql");
         Dream.get "/inc" (fun req ->
             match Dream.query req "num" with
             | Some num ->
                 Main.Rust.increment_ints_list [ int_of_string num ]
                 |> List.map string_of_int
                 |> String.concat ","
                 |> Dream.html
             | None -> Dream.html "");
         Dream.get "/relation" (fun req ->
             let from = Dream.query req "from" in
             let to' = Dream.query req "to" in
             match (from, to') with
             | Some from, Some to' ->
                 Storage.Queries.create_shortest_path from to'
                 |> Storage.Redis.run_cypher_query
                 >|= Storage.Queries.get_json_response_from_reply
                 >|= Option.get
                 >|= utf_decimal_decode
                 >>= Dream.json
             | _ -> Dream.respond "");
         Dream.get "/save_artist/:artist_uri" (fun req ->
             match Some (Dream.param req "artist_uri") with
             | Some uri ->
                 Main.persist_all_tracks_from_artist_id uri
                 |> Main.string_of_reply_reply_list
                 >|= yojson_fold
                 >|= Yojson.Safe.to_string
                 >>= Dream.json
             | None -> Dream.respond ~status:`Bad_Request "");
       ]

let lines ?encoding (src : [ `Channel of in_channel | `String of string ]) =
  let rec loop d buf acc =
    match Uutf.decode d with
    | `Uchar u -> (
        match Uchar.to_int u with
        | 0x000A ->
            let line = Buffer.contents buf in
            Buffer.clear buf;
            loop d buf (line :: acc)
        | _ ->
            Uutf.Buffer.add_utf_8 buf u;
            loop d buf acc)
    | `End -> List.rev (Buffer.contents buf :: acc)
    | `Malformed _ ->
        Uutf.Buffer.add_utf_8 buf Uutf.u_rep;
        loop d buf acc
    | `Await -> assert false
  in
  let nln = `Readline (Uchar.of_int 0x000A) in
  loop (Uutf.decoder ~nln ?encoding src) (Buffer.create 512) []
