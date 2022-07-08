(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    (* A JSON array of the [Spotify IDs](/documentation/web-api/#spotify-uris-and-ids). <br>A maximum of 50 items can be specified in one request. _**Note**: if the `ids` parameter is present in the query string, any IDs listed here in the body will be ignored._  *)
    ids: string list;
} [@@deriving yojson { strict = false }, show ];;

let create () : t = {
    ids = [];
}

