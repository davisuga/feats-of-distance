(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* The copyright text for this content.  *)
  text : string option; [@default None]
  (* The type of copyright: `C` = the copyright, `P` = the sound recording (performance) copyright.  *)
  _type : string option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t = { text = None; _type = None }
