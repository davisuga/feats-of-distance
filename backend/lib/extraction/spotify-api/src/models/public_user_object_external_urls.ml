(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 * Schema Public_user_object_external_urls.t : Known public external URLs for this user. 
 *)

type t = {
  (* The [Spotify URL](/documentation/web-api/#spotify-uris-and-ids) for the object.  *)
  spotify : string option; [@default None]
}
[@@deriving yojson { strict = false }, show]

(** Known public external URLs for this user.  *)
let create () : t = { spotify = None }
