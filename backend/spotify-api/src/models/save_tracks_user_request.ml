(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
    (* A JSON array of the [Spotify IDs](/documentation/web-api/#spotify-uris-and-ids). For example: `[\''4iV5W9uYEdYUVa79Axb7Rh\'', \''1301WleyT98MSxVHPZCA6M\'']`<br>A maximum of 50 items can be specified in one request. _**Note**: if the `ids` parameter is present in the query string, any IDs listed here in the body will be ignored._  *)
    ids: string list;
} [@@deriving yojson { strict = false }, show ];;

let create (ids : string list) : t = {
    ids = ids;
}

