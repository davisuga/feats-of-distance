(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    items: Simplified_playlist_object.t list;
} [@@deriving yojson { strict = false }, show ];;

let create () : t = {
    items = [];
}

