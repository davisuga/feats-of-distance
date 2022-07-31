(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* The new name for the playlist, for example `\''My New Playlist Title\''`  *)
  name : string option; [@default None]
  (* If `true` the playlist will be public, if `false` it will be private.  *)
  public : bool option; [@default None]
  (* If `true`, the playlist will become collaborative and other users will be able to modify the playlist in their Spotify client. <br> _**Note**: You can only set `collaborative` to `true` on non-public playlists._  *)
  collaborative : bool option; [@default None]
  (* Value for playlist description as displayed in Spotify Clients and in the Web API.  *)
  description : string option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t =
  { name = None; public = None; collaborative = None; description = None }
