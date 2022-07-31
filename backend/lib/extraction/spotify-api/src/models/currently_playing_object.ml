(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  context : Currently_playing_object_context.t option; [@default None]
  (* Unix Millisecond Timestamp when data was fetched *)
  timestamp : int32 option; [@default None]
  (* Progress into the currently playing track or episode. Can be `null`. *)
  progress_ms : int32 option; [@default None]
  (* If something is currently playing, return `true`. *)
  is_playing : bool option; [@default None]
  item : Currently_playing_object_item.t option; [@default None]
  (* The object type of the currently playing item. Can be one of `track`, `episode`, `ad` or `unknown`.  *)
  currently_playing_type : string option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t =
  {
    context = None;
    timestamp = None;
    progress_ms = None;
    is_playing = None;
    item = None;
    currently_playing_type = None;
  }
