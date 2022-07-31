open! Utils
open! Http
open Dto_lens
open! Printf
open Domain
open Lwt.Infix
(* let get_artists_of_track_item (track_json : Dtos.genres_item) = (track_json |> map_song_from_json) *)

let map_song_from_json_if_valid track_json =
  if List.length (get_artists_of_track track_json) < 2 then None
  else Some (map_song_from_json track_json)

let map_album_tracks_result_to_domain album_tracks_result =
  get_tracks_of_album_query_result album_tracks_result
  |> List.filter_map map_song_from_json_if_valid

let persist_album_tracks_result album_tracks =
  map_album_tracks_result_to_domain album_tracks
  |> List.map Storage.Queries.create_song
  |> log "persist_album_tracks_result"
  |> N4J.run_cypher_queries_cmd ~sort:true

let get_and_persist_album_tracks album_id =
  Http.get_album_tracks album_id
  |> log ("got album tracks for " ^ album_id)
  >>= persist_album_tracks_result

let persist_all_tracks_from_artist_id_exn artist_id =
  artist_id
  |> Http.get_albums_uris_by_artist_uri
  >|= log ("got albums and singles by " ^ artist_id)
  >>= Lwt_list.map_s get_and_persist_album_tracks

let format_yojson_error ex yojson file line =
  sprintf "%s:%d\n Failed to parse %s. \n Error: %s" file line
    (Yojson.Safe.show yojson) (Printexc.to_string ex)

let persist_all_tracks_from_artist_id_opt artist_id =
  try
    try%lwt persist_all_tracks_from_artist_id_exn artist_id >|= Option.some
    with exn ->
      let msg =
        sprintf "Error while saving %s: %s" artist_id (Printexc.to_string exn)
      in
      Dream.log "%s" msg;
      Lwt.return_none
  with
  | Ppx_yojson_conv_lib__Yojson_conv.Of_yojson_error (err, yojson) ->
      let msg = format_yojson_error err yojson __FILE__ __LINE__ in
      Dream.log "%s" msg;
      Lwt.return_none
  | Failure f ->
      Dream.log "Failure happend: %s" f;
      Lwt.return_none
  | e ->
      Dream.log "%s" (Printexc.to_string e);
      Lwt.return_none

let seed_from_fs () =
  let%lwt saved = Artist_service.get_all_saved () in
  Core.In_channel.read_lines "~/neo4j/import/relevant_artists.csv"
  |> Core.List.filter ~f:(fun item ->
         not (List.mem ("spotify:artist:" ^ item) saved))
  |> Core.List.groupi ~break:(fun i _ _ -> i mod 100 = 0)
  |> log "lines read"
  |> Lwt_list.map_s
       (Lwt_list.filter_map_p (fun csv_line ->
            let cols = String.split_on_char ',' csv_line in
            let id = List.nth cols 1 in
            let name = List.nth cols 0 in
            let uri = "spotify:artist:" ^ id in
            (* let  = String.split_on_char ',' csv_line in *)
            persist_all_tracks_from_artist_id_opt uri
            >|= logInfo ("saved " ^ name ^ ":" ^ id)
            >>= fun x ->
            let%lwt _ =
              Storage.Queries.mark_artist_as_saved uri |> N4J.run_cypher_query
            in
            Lwt.return x))
  >|= List.flatten

let test () =
  seed_from_fs ()
  >|= List.map concat_json_strings
  >|= concat_json_strings
  >|= print_string
  |> Lwt_main.run
