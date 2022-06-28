(* name * uri *)
type song_author = string * string
type song = { name : string; authors : (string * string) list; id : string }
type album = { name : string; id : string; cover_art_url : string; year : int }
type artist = { name : string; id : string; img : string option }
