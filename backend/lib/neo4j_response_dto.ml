type row = { name : string; id : string }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type meta = { id : int; deleted : bool }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type datum = { row : row list list; meta : meta list list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type result = { columns : string list; data : datum list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type position = { offset : int; line : int; column : int }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type notification = {
  code : string;
  severity : string;
  title : string;
  description : string;
  position : position;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type neo4j_response = {
  results : result list;
  notifications : notification list; (* errors : string option list; *)
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]
