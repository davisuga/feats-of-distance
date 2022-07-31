(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 * Schema Track_object_linked_from.t : Part of the response when [Track Relinking](/documentation/general/guides/track-relinking-guide/) is applied, and the requested track has been replaced with different track. The track in the `linked_from` object contains information about the originally requested track. 
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

(** Part of the response when [Track Relinking](/documentation/general/guides/track-relinking-guide/) is applied, and the requested track has been replaced with different track. The track in the `linked_from` object contains information about the originally requested track.  *)
let create () : t =
  { external_urls = None; href = None; id = None; _type = None; uri = None }
