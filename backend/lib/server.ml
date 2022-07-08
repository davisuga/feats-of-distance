open Models
open Utils

let artist =
  Graphql_lwt.Schema.(
    obj "Artist" ~fields:(fun _info ->
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

let properties =
  Graphql_lwt.Schema.(
    obj "Properties" ~fields:(fun _info ->
        [
          field "id" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info (prop : N4j_path_dto.properties) -> prop.id);
          field "name" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info (prop : N4j_path_dto.properties) -> prop.name);
        ]))

let node =
  Graphql_lwt.Schema.(
    obj "Node" ~fields:(fun _info ->
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
        ]))

let feat =
  let open N4j_path_dto in
  Graphql_lwt.Schema.(
    obj "Feature" ~fields:(fun _info ->

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
                Http.search_artists term >|= Array.to_list >|= Result.ok
            | None -> Lwt.return (Result.Error "Empty search term"));
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
                Storage.Queries.create_shortest_path
                  ~limit:(Option.value limit ~default:2)
                  from to'
                |> N4J.run_cypher_query
                >|= N4J.get_json_response_from_reply
                >|= Option.map utf_decimal_decode
                >|= Option.get
                >|= Yojson.Safe.from_string
                >|= N4j_path_dto.path_response_dto_of_yojson
                >|= N4j_path_dto.relations_of_response
                >|= Result.ok
            | _ -> Lwt.return (Result.Error "Invalid params"));
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

open! Printf

type command_body = { command : string } [@@deriving yojson]

let command_route =
  Dream.post "/command" (fun req ->
      Dream.body req
      >|= Yojson.Safe.from_string
      >|= command_body_of_yojson
      >>= (fun command -> N4J.run_cypher_query command.command)
      >>= Dream.json)

let run =
  Dream.post "/run" (fun req ->
      Dream.body req
      >|= Yojson.Safe.from_string
      >|= command_body_of_yojson
      >>= (fun command -> Utils.run command.command)
      >>= Dream.html)

let start port =
  Dream.run ~port ~interface:"0.0.0.0" ~adjust_terminal:false
  @@ Dream.logger
  @@ cors_middleware
  @@ Dream.router
       [
         Dream.post "/graphql" (Dream.graphql Lwt.return schema);
         command_route;
         run;
         Dream.options "/graphql" (fun _req ->
             Dream.respond ~headers:[ ("Allow", "OPTIONS, GET, HEAD, POST") ] "");
         Dream.get "/" (Dream.graphiql "/graphql");
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
                 Scrapper.persist_all_tracks_from_artist_id uri
                 >|= Option.get
                 >|= List.map Yojson.Safe.from_string
                 >|= yojson_fold
                 >|= Yojson.Safe.to_string
                 >>= Dream.json
             | None -> Dream.respond ~status:`Bad_Request "");
       ]
