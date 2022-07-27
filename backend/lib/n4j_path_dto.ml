type properties = { name : string; uri : string }
[@@deriving yojson] [@@yojson.allow_extra_fields]

type node = { id : string; properties : properties; labels : string list }
[@@deriving yojson] [@@yojson.allow_extra_fields]

type relationship = {
  start : node;
  end_ : node; [@key "end"]
  id : string;
  label : string;
  properties : properties;
}
[@@deriving yojson] [@@yojson.allow_extra_fields]

type item = Node of node | Relationship of relationship

let item_of_yojson item =
  if List.mem "start" (Yojson.Safe.Util.keys item) then
    Relationship (relationship_of_yojson item)
  else Node (node_of_yojson item)

let yojson_of_item = function
  | Node node -> yojson_of_node node
  | Relationship rel -> yojson_of_relationship rel

type found_path = item list [@@deriving yojson]
type path_response_dto = found_path list [@@deriving yojson]

let get_if_relationship = function Node _ -> None | Relationship r -> Some r

let relations_of_response (path : path_response_dto) =
  List.flatten path |> List.filter_map get_if_relationship
