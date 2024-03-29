open Models
open Utils
open Graphql

let artist =
  Graphql_lwt.Schema.(
    obj "Artist"
      ~fields:
        [
          field "uri" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info artist -> artist.uri);
          field "name" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info artist -> artist.name);
          field "img" ~typ:string
            ~args:Arg.[]
            ~resolve:(fun _info artist -> artist.img);
          field "description" ~typ:string
            ~args:Arg.[]
            ~resolve:(fun _info artist -> artist.description);
        ])

let properties =
  Graphql_lwt.Schema.(
    obj "Properties"
      ~fields:
        [
          field "uri" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info (prop : N4j_path_dto.properties) -> prop.uri);
          field "name" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info (prop : N4j_path_dto.properties) -> prop.name);
        ])

let node =
  Graphql_lwt.Schema.(
    obj "Node"
      ~fields:
        [
          field "id" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info (prop : N4j_path_dto.node) -> prop.id);
          field "properties" ~typ:(non_null properties)
            ~args:Arg.[]
            ~resolve:(fun _info (prop : N4j_path_dto.node) -> prop.properties);
          field "labels"
            ~typ:(non_null (list (non_null string)))
            ~args:Arg.[]
            ~resolve:(fun _info (prop : N4j_path_dto.node) -> prop.labels);
        ])

let feat =
  let open N4j_path_dto in
  Graphql_lwt.Schema.(
    obj "Feature"
      ~fields:
        [
          field "uri" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info relation -> relation.id);
          field "properties" ~typ:(non_null properties)
            ~args:Arg.[]
            ~resolve:(fun _info relation -> relation.properties);
          field "start" ~typ:(non_null node)
            ~args:Arg.[]
            ~resolve:(fun _info relation -> relation.start);
          field "end" ~typ:(non_null node)
            ~args:Arg.[]
            ~resolve:(fun _info relation -> relation.end_);
        ])

open! Lwt.Infix

let schema =
  Graphql_lwt.Schema.(
    schema
      [
        io_field "artists"
          ~typ:(non_null (list (non_null artist)))
          ~args:Arg.[ arg "search_term" ~typ:string ]
          ~resolve:(fun _info _ search_term ->
            match search_term with
            | Some term ->
                Http.search_artists term >|= Array.to_list >|= Result.ok
            | None -> Lwt.return (Result.Error "Empty search term"));
        io_field "artist" ~typ:(non_null node)
          ~args:Arg.[ arg "uri" ~typ:string ]
          ~resolve:(fun _info () uri ->
            match uri with
            | Some uri -> Artist_service.get_one uri >|= Result.ok
            | None -> Lwt.return (Result.Error "Empty or invalid uri"));
        io_field "features"
          ~typ:(non_null (list (non_null feat)))
          ~args:
            Arg.
              [
                arg "from" ~typ:string;
                arg "to" ~typ:string;
                arg "limit" ~typ:int;
              ]
          ~resolve:(fun _info () from to_ limit ->
            match (from, to_) with
            | Some from, Some to' ->
                Features_service.features_of_distance ~limit from to'
                >|= Result.ok
            | _ -> Lwt.return (Result.Error "Invalid params"));
      ])

open Lwt.Syntax

let add_headers new_headers msg =
  new_headers
  |> List.map (fun (key, value) -> Dream.add_header msg key value)
  |> ignore;
  msg

let cors_middleware inner_handler req =
  let new_headers =
    [
      ("Allow", "OPTIONS, GET, HEAD, POST");
      ("Access-Control-Allow-Origin", "*");
      ("Access-Control-Allow-Headers", "*");
    ]
  in
  let+ response = inner_handler req in
  response |> add_headers new_headers

open! Printf

type command_body = { command : string } [@@deriving yojson]

let command_route =
  Dream.post "/command" (fun req ->
      Dream.body req
      >|= Yojson.Safe.from_string
      >|= command_body_of_yojson
      >>= (fun command -> N4J.run_cypher_query command.command)
      >>= Dream.json)

let handle_run req =
  Dream.body req
  >|= Yojson.Safe.from_string
  >|= command_body_of_yojson
  >>= (fun command -> Utils.run command.command)
  |> Lwt_result.map_error (fun e ->
         Dream.log "OOPS: %s" (Printexc.to_string e);
         e)
  |> Lwt_result.get_exn
  >>= Dream.html

let run = Dream.post "/run" handle_run
let token = Dream.get "/token" (fun req -> Http.new_token () >>= Dream.html)

let graphql_routes =
  [
    Dream.post "/graphql" (Dream.graphql Lwt.return schema);
    Dream.options "/graphql" (fun _req ->
        Dream.respond ~headers:[ ("Allow", "OPTIONS, GET, HEAD, POST") ] "");
    Dream.get "/" (Dream.graphiql "/graphql");
  ]

let main_routes =
  List.append graphql_routes
    [
      command_route;
      token;
      run;
      Dream.get "/relation" (fun req ->
          let from = Dream.query req "from" in
          let to' = Dream.query req "to" in
          match (from, to') with
          | Some from, Some to' ->
              Storage.Queries.create_shortest_path from to'
              |> N4J.run_cypher_query
              >|= N4J.get_json_response_from_reply
              >|= Option.map utf_decimal_decode
              >|= Option.get
              >>= Dream.json
          | _ -> Dream.respond "");
      Dream.get "/save_artist/:artist_uri" (fun req ->
          match Some (Dream.param req "artist_uri") with
          | Some uri ->
              Scrapper.persist_all_tracks_from_artist_id_opt uri
              >|= Option.get
              >|= List.map Yojson.Safe.from_string
              >|= yojson_fold
              >|= Yojson.Safe.to_string
              >>= Dream.json
          | None -> Dream.respond ~status:`Bad_Request "");
    ]

let start port =
  Dream.run ~port ~interface:"0.0.0.0" ~adjust_terminal:false
  @@ Dream.logger
  @@ cors_middleware
  @@ Dream.router [ Dream.scope "/" [] main_routes ]
