type 'a t = {
  (* The total number of items available to return.  *)
  total : int32;
  (* The offset of the items returned (as set in the query or by default)  *)
  offset : int32;
  limit : int32;
  items : 'a list;
}
[@@deriving yojson { strict = false }, show]
