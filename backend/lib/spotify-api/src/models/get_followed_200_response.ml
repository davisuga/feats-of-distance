(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    artists: Get_followed_200_response_artists.t;
} [@@deriving yojson { strict = false }, show ];;

let create (artists : Get_followed_200_response_artists.t) : t = {
    artists = artists;
}
