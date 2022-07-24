(* name * uri *)
type song_author = string * string [@@deriving yojson]

type song = { name : string; authors : (string * string) list; uri : string }
[@@deriving yojson]

(* song_name, *)
type album = {
  name : string;
  uri : string;
  cover_art_url : string;
  year : int;
  album : string option;
}
[@@deriving yojson]

type artist = {
  name : string;
  uri : string;
  img : string option;
  description : string option;
}
[@@deriving yojson]
