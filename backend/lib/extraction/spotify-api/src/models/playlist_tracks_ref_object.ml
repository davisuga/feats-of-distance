(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    (* A link to the Web API endpoint where full details of the playlist's tracks can be retrieved.  *)
    href: string option [@default None];
    (* Number of tracks in the playlist.  *)
    total: int32 option [@default None];
} [@@deriving yojson { strict = false }, show ];;

let create () : t = {
    href = None;
    total = None;
}
