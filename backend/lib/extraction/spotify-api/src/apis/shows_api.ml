(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

let check_users_saved_shows ~ids =
    let open Lwt.Infix in
    let uri = Request.build_uri "/me/shows/contains" in
    let headers = Request.default_headers in
    let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
    Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
    Request.read_json_body_as_list_of (JsonSupport.to_bool) resp body

let get_a_show ~id ?market () =
    let open Lwt.Infix in
    let uri = Request.build_uri "/shows/{id}" in
    let headers = Request.default_headers in
    let uri = Request.replace_path_param uri "id" (fun x -> x) id in
    let uri = Request.maybe_add_query_param uri "market" (fun x -> x) market in
    Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
    Request.read_json_body_as (JsonSupport.unwrap Show_object.of_yojson) resp body

let get_a_shows_episodes ~id ?market ?(limit = 20l) ?(offset = 0l) () =
    let open Lwt.Infix in
    let uri = Request.build_uri "/shows/{id}/episodes" in
    let headers = Request.default_headers in
    let uri = Request.replace_path_param uri "id" (fun x -> x) id in
    let uri = Request.maybe_add_query_param uri "market" (fun x -> x) market in
    let uri = Request.add_query_param uri "limit" Int32.to_string limit in
    let uri = Request.add_query_param uri "offset" Int32.to_string offset in
    Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
    Request.read_json_body_as (JsonSupport.unwrap Episodes_paging_object.of_yojson) resp body

let get_multiple_shows ~ids ?market () =
    let open Lwt.Infix in
    let uri = Request.build_uri "/shows" in
    let headers = Request.default_headers in
    let uri = Request.maybe_add_query_param uri "market" (fun x -> x) market in
    let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
    Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
    Request.read_json_body_as (JsonSupport.unwrap Get_multiple_shows_200_response.of_yojson) resp body

let get_users_saved_shows ?(limit = 20l) ?(offset = 0l) () =
    let open Lwt.Infix in
    let uri = Request.build_uri "/me/shows" in
    let headers = Request.default_headers in
    let uri = Request.add_query_param uri "limit" Int32.to_string limit in
    let uri = Request.add_query_param uri "offset" Int32.to_string offset in
    Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
    Request.read_json_body_as (JsonSupport.unwrap Get_users_saved_shows_200_response.of_yojson) resp body

let remove_shows_user ~ids ?market ~save_shows_user_request_t () =
    let open Lwt.Infix in
    let uri = Request.build_uri "/me/shows" in
    let headers = Request.default_headers in
    let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
    let uri = Request.maybe_add_query_param uri "market" (fun x -> x) market in
    let body = Request.write_as_json_body Save_shows_user_request.to_yojson save_shows_user_request_t in
    Cohttp_lwt_unix.Client.call `DELETE uri ~headers ~body >>= fun (resp, body) ->
    Request.handle_unit_response resp

let save_shows_user ~ids ~save_shows_user_request_t () =
    let open Lwt.Infix in
    let uri = Request.build_uri "/me/shows" in
    let headers = Request.default_headers in
    let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
    let body = Request.write_as_json_body Save_shows_user_request.to_yojson save_shows_user_request_t in
    Cohttp_lwt_unix.Client.call `PUT uri ~headers ~body >>= fun (resp, body) ->
    Request.handle_unit_response resp
