(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = { tracks : Track_object.t list }
[@@deriving yojson { strict = false }, show]

let create (tracks : Track_object.t list) : t = { tracks }
