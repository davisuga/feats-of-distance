(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* This will always be set to null, as the Web API does not support it at the moment.  *)
  href : string option; [@default None]
  (* The total number of followers.  *)
  total : int32 option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t = { href = None; total = None }
