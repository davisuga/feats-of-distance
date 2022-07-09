(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)
type offset = {
    position: int32
}[@@deriving yojson { strict = false }, show ];;

type t = {
    (* Optional. Spotify URI of the context to play. Valid contexts are albums, artists & playlists. {context_uri:\''spotify:album:1Je1IMUlBXcx1Fz0WE7oPT\''}  *)
    context_uri: string option [@default None];
    (* Optional. A JSON array of the Spotify track URIs to play. For example: {\''uris\'': [\''spotify:track:4iV5W9uYEdYUVa79Axb7Rh\'', \''spotify:track:1301WleyT98MSxVHPZCA6M\'']}  *)
    uris: string list;
    (* Optional. Indicates from where in the context playback should start. Only available when context_uri corresponds to an album or playlist object \''position\'' is zero based and can’t be negative. Example: \''offset\'': {\''position\'': 5} \''uri\'' is a string representing the uri of the item to start at. Example: \''offset\'': {\''uri\'': \''spotify:track:1301WleyT98MSxVHPZCA6M\''}  *)
    offset: (string * offset) list;
    (* Indicates from what position to start playback. Must be a positive number. Passing in a position that is greater than the length of the track will cause the player to start playing the next song.  *)
    position_ms: int32 option [@default None];
} [@@deriving yojson { strict = false }, show ];;

let create () : t = {
    context_uri = None;
    uris = [];
    offset = [];
    position_ms = None;
}

