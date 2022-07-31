(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* A link to the Web API endpoint returning the full result of the request. *)
  href : string option; [@default None]
  items : Play_history_object.t list;
  (* The maximum number of items in the response (as set in the query or by default). *)
  limit : int32 option; [@default None]
  (* URL to the next page of items. ( `null` if none) *)
  next : string option; [@default None]
  cursors : Cursor_paging_object_cursors.t option; [@default None]
  (* The total number of items available to return. *)
  total : int32 option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t =
  {
    href = None;
    items = [];
    limit = None;
    next = None;
    cursors = None;
    total = None;
  }
