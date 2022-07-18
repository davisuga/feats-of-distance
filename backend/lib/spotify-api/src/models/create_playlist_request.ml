(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    (* The name for the new playlist, for example `\''Your Coolest Playlist\''`. This name does not need to be unique; a user may have several playlists with the same name.  *)
    name: string;
    (* Defaults to `true`. If `true` the playlist will be public, if `false` it will be private. To be able to create private playlists, the user must have granted the `playlist-modify-private` [scope](/documentation/general/guides/authorization-guide/#list-of-scopes)  *)
    public: bool option [@default None];
    (* Defaults to `false`. If `true` the playlist will be collaborative. _**Note**: to create a collaborative playlist you must also set `public` to `false`. To create collaborative playlists you must have granted `playlist-modify-private` and `playlist-modify-public` [scopes](/documentation/general/guides/authorization-guide/#list-of-scopes)._  *)
    collaborative: bool option [@default None];
    (* value for playlist description as displayed in Spotify Clients and in the Web API.  *)
    description: string option [@default None];
} [@@deriving yojson { strict = false }, show ];;

let create (name : string) : t = {
    name = name;
    public = None;
    collaborative = None;
    description = None;
}
