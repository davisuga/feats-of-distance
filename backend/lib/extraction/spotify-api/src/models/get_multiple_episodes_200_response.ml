(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    episodes: Episode_object.t list;
} [@@deriving yojson { strict = false }, show ];;

let create (episodes : Episode_object.t list) : t = {
    episodes = episodes;
}
