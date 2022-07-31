(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* The date and time the episode was saved. Timestamps are returned in ISO 8601 format as Coordinated Universal Time (UTC) with a zero offset: YYYY-MM-DDTHH:MM:SSZ.  *)
  added_at : string option; [@default None]
  episode : Saved_episode_object_episode.t option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t = { added_at = None; episode = None }
