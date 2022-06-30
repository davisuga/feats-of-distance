open Models
open Utils

let artist =
  Graphql_lwt.Schema.(
    obj "user" ~fields:(fun _info ->
        [
          field "uri" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info user -> user.id);
          field "name" ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _info user -> user.name);
          field "img" ~typ:string
            ~args:Arg.[]
            ~resolve:(fun _info user -> user.img);
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

(* let default_query = "{\\n  users {\\n    name\\n    id\\n  }\\n}\\n" *)

let start port =
  Dream.run ~port
  @@ Dream.logger
  @@ Dream.origin_referrer_check
  @@ Dream.router
       [
         Dream.any "/graphql" (Dream.graphql Lwt.return schema);
         Dream.get "/" (Dream.graphiql "/graphql");
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
