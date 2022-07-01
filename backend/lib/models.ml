(* name * uri *)
type song_author = string * string [@@deriving yojson]

type song = { name : string; authors : (string * string) list; id : string }
[@@deriving yojson]

type album = { name : string; id : string; cover_art_url : string; year : int }
[@@deriving yojson]

type artist = { name : string; id : string; img : string option }
[@@deriving yojson]
