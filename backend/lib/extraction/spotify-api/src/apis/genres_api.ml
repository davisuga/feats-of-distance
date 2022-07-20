(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

let get_recommendation_genres () =
    let open Lwt.Infix in
    let uri = Request.build_uri "/recommendations/available-genre-seeds" in
    let headers = Request.default_headers in
    Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
    Request.read_json_body_as (JsonSupport.unwrap Get_recommendation_genres_200_response.of_yojson) resp body
