(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = Simplified_album_object.t Paged.t
[@@deriving yojson { strict = false }, show]

let create (href : string) (items : Simplified_album_object.t list)
    (limit : int32) (next : string option) (offset : int32)
    (previous : string option) (total : int32) : t =
  {
    (* href = href; *)
    items;
    limit;
    (* next = next; *)
    offset;
    (* previous = previous; *)
    total;
  }
