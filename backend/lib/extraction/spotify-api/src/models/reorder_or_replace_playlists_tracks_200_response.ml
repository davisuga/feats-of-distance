(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = { snapshot_id : string option [@default None] }
[@@deriving yojson { strict = false }, show]

let create () : t = { snapshot_id = None }
