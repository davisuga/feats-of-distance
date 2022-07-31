(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 * Schema Simplified_playlist_object_tracks.t : A collection containing a link ( `href` ) to the Web API endpoint where full details of the playlist's tracks can be retrieved, along with the `total` number of tracks in the playlist. Note, a track object may be `null`. This can happen if a track is no longer available. 
 *)

type t = {
  (* A link to the Web API endpoint where full details of the playlist's tracks can be retrieved.  *)
  href : string option; [@default None]
  (* Number of tracks in the playlist.  *)
  total : int32 option; [@default None]
}
[@@deriving yojson { strict = false }, show]

(** A collection containing a link ( `href` ) to the Web API endpoint where full details of the playlist's tracks can be retrieved, along with the `total` number of tracks in the playlist. Note, a track object may be `null`. This can happen if a track is no longer available.  *)
let create () : t = { href = None; total = None }
