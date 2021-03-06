(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  external_urls : Linked_track_object_external_urls.t option; [@default None]
  (* A link to the Web API endpoint providing full details of the track.  *)
  href : string option; [@default None]
  (* The [Spotify ID](/documentation/web-api/#spotify-uris-and-ids) for the track.  *)
  id : string option; [@default None]
  (* The object type: \''track\''.  *)
  _type : string option; [@default None]
  (* The [Spotify URI](/documentation/web-api/#spotify-uris-and-ids) for the track.  *)
  uri : string option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t =
  { external_urls = None; href = None; id = None; _type = None; uri = None }
