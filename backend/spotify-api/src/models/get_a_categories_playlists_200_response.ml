(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    playlists: Playlists_paging_object.t;
} [@@deriving yojson { strict = false }, show ];;

let create (playlists : Playlists_paging_object.t) : t = {
    playlists = playlists;
}

