(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    (* Defaults to `true`. If `true` the playlist will be included in user's public playlists, if `false` it will remain private.  *)
    public: bool option [@default None];
} [@@deriving yojson { strict = false }, show ];;

let create () : t = {
    public = None;
}
