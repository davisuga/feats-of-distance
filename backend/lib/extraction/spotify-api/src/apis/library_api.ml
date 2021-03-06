(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

(* let change_playlist_details ~playlist_id ~request_body () =
    let open Lwt.Infix in
    let uri = Request.build_uri "/playlists/{playlist_id}" in
    let headers = Request.default_headers in
    let uri = Request.replace_path_param uri "playlist_id" (fun x -> x) playlist_id in
    let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
    Cohttp_lwt_unix.Client.call `PUT uri ~headers ~body >>= fun (resp, body) ->
    Request.handle_unit_response resp *)

let check_current_user_follows ~_type ~ids =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/following/contains" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "type" Enums.show_type_0 _type in
  let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as_list_of JsonSupport.to_bool resp body

let check_users_saved_albums ~ids =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/albums/contains" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as_list_of JsonSupport.to_bool resp body

let check_users_saved_episodes ~ids =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/episodes/contains" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as_list_of JsonSupport.to_bool resp body

let check_users_saved_shows ~ids =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/shows/contains" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as_list_of JsonSupport.to_bool resp body

let check_users_saved_tracks ~ids =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/tracks/contains" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as_list_of JsonSupport.to_bool resp body

(* let create_playlist ~user_id ~request_body () =
       let open Lwt.Infix in
       let uri = Request.build_uri "/users/{user_id}/playlists" in
       let headers = Request.default_headers in
       let uri = Request.replace_path_param uri "user_id" (fun x -> x) user_id in
       let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
       Cohttp_lwt_unix.Client.call `POST uri ~headers ~body >>= fun (resp, body) ->
       Request.read_json_body_as (JsonSupport.unwrap Playlist_object.of_yojson) resp body

   let follow_artists_users ~_type ~ids ~request_body () =
       let open Lwt.Infix in
       let uri = Request.build_uri "/me/following" in
       let headers = Request.default_headers in
       let uri = Request.add_query_param uri "type" Enums.show_type_0 _type in
       let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
       let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
       Cohttp_lwt_unix.Client.call `PUT uri ~headers ~body >>= fun (resp, body) ->
       Request.handle_unit_response resp *)

let get_a_list_of_current_users_playlists ?(limit = 20l) ?(offset = 0l) () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/playlists" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "limit" Int32.to_string limit in
  let uri = Request.add_query_param uri "offset" Int32.to_string offset in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as
    (JsonSupport.unwrap Playlists_paging_object.of_yojson)
    resp body

let get_followed ~_type ?after ?(limit = 20l) () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/following" in
  let headers = Request.default_headers in
  let uri =
    Request.add_query_param uri "type" Enums.show_artistobject_type _type
  in
  let uri = Request.maybe_add_query_param uri "after" (fun x -> x) after in
  let uri = Request.add_query_param uri "limit" Int32.to_string limit in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as
    (JsonSupport.unwrap Get_followed_200_response.of_yojson)
    resp body

let get_users_saved_albums ?(limit = 20l) ?(offset = 0l) ?market () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/albums" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "limit" Int32.to_string limit in
  let uri = Request.add_query_param uri "offset" Int32.to_string offset in
  let uri = Request.maybe_add_query_param uri "market" (fun x -> x) market in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as
    (JsonSupport.unwrap Get_users_saved_albums_200_response.of_yojson)
    resp body

let get_users_saved_episodes ?market ?(limit = 20l) ?(offset = 0l) () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/episodes" in
  let headers = Request.default_headers in
  let uri = Request.maybe_add_query_param uri "market" (fun x -> x) market in
  let uri = Request.add_query_param uri "limit" Int32.to_string limit in
  let uri = Request.add_query_param uri "offset" Int32.to_string offset in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as
    (JsonSupport.unwrap Get_users_saved_episodes_200_response.of_yojson)
    resp body

let get_users_saved_shows ?(limit = 20l) ?(offset = 0l) () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/shows" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "limit" Int32.to_string limit in
  let uri = Request.add_query_param uri "offset" Int32.to_string offset in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as
    (JsonSupport.unwrap Get_users_saved_shows_200_response.of_yojson)
    resp body

let get_users_saved_tracks ?market ?(limit = 20l) ?(offset = 0l) () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/tracks" in
  let headers = Request.default_headers in
  let uri = Request.maybe_add_query_param uri "market" (fun x -> x) market in
  let uri = Request.add_query_param uri "limit" Int32.to_string limit in
  let uri = Request.add_query_param uri "offset" Int32.to_string offset in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as
    (JsonSupport.unwrap Get_users_saved_tracks_200_response.of_yojson)
    resp body

let get_users_top_artists ?(time_range = "medium_term") ?(limit = 20l)
    ?(offset = 0l) () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/top/artists" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "time_range" (fun x -> x) time_range in
  let uri = Request.add_query_param uri "limit" Int32.to_string limit in
  let uri = Request.add_query_param uri "offset" Int32.to_string offset in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as
    (JsonSupport.unwrap Artists_paging_object.of_yojson)
    resp body

let get_users_top_tracks ?(time_range = "medium_term") ?(limit = 20l)
    ?(offset = 0l) () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/top/tracks" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "time_range" (fun x -> x) time_range in
  let uri = Request.add_query_param uri "limit" Int32.to_string limit in
  let uri = Request.add_query_param uri "offset" Int32.to_string offset in
  Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) ->
  Request.read_json_body_as
    (JsonSupport.unwrap Tracks_paging_object.of_yojson)
    resp body

(* let remove_albums_user ~ids ~request_body () =
       let open Lwt.Infix in
       let uri = Request.build_uri "/me/albums" in
       let headers = Request.default_headers in
       let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
       let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
       Cohttp_lwt_unix.Client.call `DELETE uri ~headers ~body >>= fun (resp, body) ->
       Request.handle_unit_response resp

   let remove_episodes_user ~ids ~request_body () =
       let open Lwt.Infix in
       let uri = Request.build_uri "/me/episodes" in
       let headers = Request.default_headers in
       let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
       let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
       Cohttp_lwt_unix.Client.call `DELETE uri ~headers ~body >>= fun (resp, body) ->
       Request.handle_unit_response resp *)

let remove_shows_user ~ids ?market ~save_shows_user_request_t () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/shows" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
  let uri = Request.maybe_add_query_param uri "market" (fun x -> x) market in
  let body =
    Request.write_as_json_body Save_shows_user_request.to_yojson
      save_shows_user_request_t
  in
  Cohttp_lwt_unix.Client.call `DELETE uri ~headers ~body >>= fun (resp, body) ->
  Request.handle_unit_response resp

(* let remove_tracks_user ~ids ~request_body () =
       let open Lwt.Infix in
       let uri = Request.build_uri "/me/tracks" in
       let headers = Request.default_headers in
       let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
       let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
       Cohttp_lwt_unix.Client.call `DELETE uri ~headers ~body >>= fun (resp, body) ->
       Request.handle_unit_response resp

   let save_albums_user ~ids ~request_body () =
       let open Lwt.Infix in
       let uri = Request.build_uri "/me/albums" in
       let headers = Request.default_headers in
       let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
       let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
       Cohttp_lwt_unix.Client.call `PUT uri ~headers ~body >>= fun (resp, body) ->
       Request.handle_unit_response resp

   let save_episodes_user ~ids ~request_body () =
       let open Lwt.Infix in
       let uri = Request.build_uri "/me/episodes" in
       let headers = Request.default_headers in
       let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
       let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
       Cohttp_lwt_unix.Client.call `PUT uri ~headers ~body >>= fun (resp, body) ->
       Request.handle_unit_response resp *)

let save_shows_user ~ids ~save_shows_user_request_t () =
  let open Lwt.Infix in
  let uri = Request.build_uri "/me/shows" in
  let headers = Request.default_headers in
  let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
  let body =
    Request.write_as_json_body Save_shows_user_request.to_yojson
      save_shows_user_request_t
  in
  Cohttp_lwt_unix.Client.call `PUT uri ~headers ~body >>= fun (resp, body) ->
  Request.handle_unit_response resp

(* let save_tracks_user ~ids ~request_body () =
       let open Lwt.Infix in
       let uri = Request.build_uri "/me/tracks" in
       let headers = Request.default_headers in
       let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
       let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
       Cohttp_lwt_unix.Client.call `PUT uri ~headers ~body >>= fun (resp, body) ->
       Request.handle_unit_response resp

   let unfollow_artists_users ~_type ~ids ~request_body () =
       let open Lwt.Infix in
       let uri = Request.build_uri "/me/following" in
       let headers = Request.default_headers in
       let uri = Request.add_query_param uri "type" Enums.show_type_0 _type in
       let uri = Request.add_query_param uri "ids" (fun x -> x) ids in
       let body = Request.write_as_json_body (JsonSupport.of_map_of ) request_body in
       Cohttp_lwt_unix.Client.call `DELETE uri ~headers ~body >>= fun (resp, body) ->
       Request.handle_unit_response resp *)
