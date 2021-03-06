(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* Interrupting playback. Optional field. *)
  interrupting_playback : bool option; [@default None]
  (* Pausing. Optional field. *)
  pausing : bool option; [@default None]
  (* Resuming. Optional field. *)
  resuming : bool option; [@default None]
  (* Seeking playback location. Optional field. *)
  seeking : bool option; [@default None]
  (* Skipping to the next context. Optional field. *)
  skipping_next : bool option; [@default None]
  (* Skipping to the previous context. Optional field. *)
  skipping_prev : bool option; [@default None]
  (* Toggling repeat context flag. Optional field. *)
  toggling_repeat_context : bool option; [@default None]
  (* Toggling shuffle flag. Optional field. *)
  toggling_shuffle : bool option; [@default None]
  (* Toggling repeat track flag. Optional field. *)
  toggling_repeat_track : bool option; [@default None]
  (* Transfering playback between devices. Optional field. *)
  transferring_playback : bool option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t =
  {
    interrupting_playback = None;
    pausing = None;
    resuming = None;
    seeking = None;
    skipping_next = None;
    skipping_prev = None;
    toggling_repeat_context = None;
    toggling_shuffle = None;
    toggling_repeat_track = None;
    transferring_playback = None;
  }
