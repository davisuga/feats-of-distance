(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* When `true`, indicates that explicit content should not be played.  *)
  filter_enabled : bool option; [@default None]
  (* When `true`, indicates that the explicit content setting is locked and can't be changed by the user.  *)
  filter_locked : bool option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t = { filter_enabled = None; filter_locked = None }
