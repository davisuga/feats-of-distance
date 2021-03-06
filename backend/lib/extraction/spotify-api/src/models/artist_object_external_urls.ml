(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 * Schema Artist_object_external_urls.t : Known external URLs for this artist. 
 *)

type t = {
  (* The [Spotify URL](/documentation/web-api/#spotify-uris-and-ids) for the object.  *)
  spotify : string option; [@default None]
}
[@@deriving yojson { strict = false }, show]

(** Known external URLs for this artist.  *)
let create () : t = { spotify = None }
