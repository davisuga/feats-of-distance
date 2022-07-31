(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* A link to the Web API endpoint returning the full result of the request  *)
  href : string;
  items : Artist_object.t list;
  (* The maximum number of items in the response (as set in the query or by default).  *)
  limit : int32;
  (* URL to the next page of items. ( `null` if none)  *)
  next : string option;
  (* The offset of the items returned (as set in the query or by default)  *)
  offset : int32;
  (* URL to the previous page of items. ( `null` if none)  *)
  previous : string option;
  (* The total number of items available to return.  *)
  total : int32;
}
[@@deriving yojson { strict = false }, show]

let create (href : string) (items : Artist_object.t list) (limit : int32)
    (next : string option) (offset : int32) (previous : string option)
    (total : int32) : t =
  { href; items; limit; next; offset; previous; total }
