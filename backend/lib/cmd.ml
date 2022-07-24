open Core
open Cmdliner

let port =
  (match (Sys.getenv "FUNCTIONS_CUSTOMHANDLER_PORT", Sys.getenv "PORT") with
  | Some p, _ -> p
  | _, Some p -> p
  | None, None -> "8081")
  |> int_of_string

let prompt =
  let verbose =
    let doc = "Displays extra log info" in
    (1, Arg.info [ "v"; "verbose" ] ~doc)
  in
  Arg.(last & vflag_all [ 0 ] [ verbose ])

let server_command =
  Cmd.v
    (Cmd.info "server" ~doc:"Starts a graphql server")
    Term.(const (fun _ -> Server.start port) $ prompt)

let seed_command =
  Cmd.v
    (Cmd.info "seed" ~doc:"Seeds the database with Spotify data")
    Term.(const (fun _ -> Scrapper.test ()) $ const ())

let cmd =
  Cmd.group (Cmd.info "Feats Of Distance") [ server_command; seed_command ]

let run () = exit (Cmd.eval cmd)
