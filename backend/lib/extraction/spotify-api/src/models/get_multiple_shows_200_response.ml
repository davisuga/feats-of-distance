(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = { shows : Simplified_show_object.t list }
[@@deriving yojson { strict = false }, show]

let create (shows : Simplified_show_object.t list) : t = { shows }
