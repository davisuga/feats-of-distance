type purple_type = string [@@deriving yojson, show]

type copyright_item = { typ : purple_type; [@key "type"] text : string }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type copyright = { items : copyright_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type source = { url : string; width : int option; height : int option }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type cover_art = { sources : source list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type precision = string [@@deriving yojson, show]

type date_class = { year : int; month : int; day : int; precision : precision }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type reason = string [@@deriving yojson, show]

type playability = { playable : bool; reason : reason }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type sharing_info = { shareId : string; shareUrl : string }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type tracks = { totalCount : int }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type fluffy_type = string [@@deriving yojson, show]

type releases_item = {
  id : string;
  uri : string;
  name : string;
  typ : fluffy_type; [@key "type"]
  copyright : copyright;
  date : date_class;
  coverArt : cover_art;
  tracks : tracks;
  label : string;
  playability : playability;
  sharingInfo : sharing_info;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type releases = { items : releases_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type artist_discography_item = { releases : releases }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type artist_discography = {
  totalCount : int;
  items : artist_discography_item list;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]
