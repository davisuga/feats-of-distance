(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 * Schema Show_base_external_urls.t : External URLs for this show. 
 *)

type t = {
    (* The [Spotify URL](/documentation/web-api/#spotify-uris-and-ids) for the object.  *)
    spotify: string option [@default None];
} [@@deriving yojson { strict = false }, show ];;

(** External URLs for this show.  *)
let create () : t = {
    spotify = None;
}

