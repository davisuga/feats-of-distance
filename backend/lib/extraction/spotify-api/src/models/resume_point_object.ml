(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* Whether or not the episode has been fully played by the user.  *)
  fully_played : bool option; [@default None]
  (* The user's most recent position in the episode in milliseconds.  *)
  resume_position_ms : int32 option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t = { fully_played = None; resume_position_ms = None }
