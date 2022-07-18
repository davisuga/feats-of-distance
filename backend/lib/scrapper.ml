open! Utils
open! Http
open! Models

module Lens = struct
  let get_first_artist_from_search_result (searchResult : Dtos.search_desktop) =
    searchResult.data.searchV2.artists.items.(0).data

  let get_tracks_of_album_query_result (album_tracks : Dtos.query_album_tracks)
      =
    album_tracks.data.album.tracks.items
end

open Lens
open! Printf

let get_ok_or fn result =
  match result with Ok something -> something | Error e -> fn e

open Domain
(* let get_artists_of_track_item (track_json : Dtos.genres_item) = (track_json |> map_song_from_json) *)

let map_song_from_json_if_valid (track_json : Dtos.genres_item) =
  if List.length track_json.track.artists.items < 2 then None
  else track_json |> map_song_from_json |> Option.some

let create_save_track_query_from_json track_json =
  map_song_from_json_if_valid track_json
  |> Option.map Storage.Queries.create_song

let save_track_from_json_file ?(prefix = "") path =
  let track_json =
    try_parse_json_with Dtos.genres_item_of_yojson ~prefix path
  in

  if List.length track_json.track.artists.items = 1 then None
  else
    track_json
    |> map_song_from_json
    |> Storage.Queries.create_song
    |> Storage.Redis.run_cypher_query
    |> Option.some

let save_artist_from_json ?(prefix = "") path =
  try_parse_json_with Http.SearchDesktop.Result.from_yojson ~prefix path
  |> get_first_artist_from_search_result
  |> map_artist_of_artist_json
  |> Storage.Queries.create_artist
  |> Storage.Redis.run_cypher_query

let read_dir path = Sys.readdir path |> Array.to_seq

let save_all_artists path =
  read_dir path |> Seq.map (save_artist_from_json ~prefix:path)

let save_all_tracks path =
  read_dir path |> Seq.filter_map (save_track_from_json_file ~prefix:path)

(* let iter_run = Seq.iter (fun prms -> Lwt_main.run prms |> ignore) *)

open! Lwt.Syntax
open Lwt.Infix

let print_string_list = List.iter (Printf.printf "%s, ")
let id a = a

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

let parmap (* fun fn a_list -> Parmap.parmap ~ncores:4 fn (Parmap.L a_list) *)
    fn a_list =
  List.fold_right
    (fun a acc ->
      try List.cons (fn a) acc
      with e ->
        Printf.eprintf "Error happened %s\n" (Printexc.to_string e);
        acc)
    a_list []

let seq_parmap
    (* fun fn a_list -> Parmap.parmap ~ncores:4 fn (Parmap.L a_list) *) fn
    a_list =
  Lwt_seq.fold_left
    (fun a acc ->
      try Lwt_seq.append acc (fn a)
      with e ->
        Printf.eprintf "Error happened %s\n" (Printexc.to_string e);
        acc)
    a_list Lwt_seq.empty

let parmap_lwt fn promise_list = parmap fn promise_list |> Lwt_list.map_s id

let seq_parmap_lwt fn promise_list =
  seq_parmap fn promise_list >|= Lwt_seq.map_s id

let persist_all_tracks_from_artist_id_exn artist_id =
  artist_id
  |> Http.get_albums_and_singles_by_artist_id
  |> log ("got albums and singles by" ^ artist_id)
  (* >|= Lwt_stream.of_list *)
  >>= Lwt_list.map_s get_and_persist_album_tracks

let persist_all_tracks_from_artist_ids_p artist_ids =
  artist_ids
  |> parmap Http.get_albums_and_singles_by_artist_id
  |> Lwt_list.map_s id
  >|= parmap (parmap_lwt Http.get_album_tracks)
  >>= Lwt_list.map_s id
  >>= Lwt_list.map_s (Lwt_list.map_s persist_album_tracks_result)

let ignore_if_raising anything = try anything () with _ -> ()

let persist_all_tracks_from_artist_id artist_id =
  try
    try%lwt persist_all_tracks_from_artist_id_exn artist_id >|= Option.some
    with exn ->
      Dream.log "Error while saving %s: %s" artist_id (Printexc.to_string exn);
      Lwt.return_none
  with
  | Ppx_yojson_conv_lib__Yojson_conv.Of_yojson_error (a, yojson) ->
      ignore_if_raising (fun () ->
          Dream.log "%s:%d\n Failed to parse %s. \n Error: %s" __FILE__ __LINE__
            (Yojson.Safe.show yojson) (Printexc.to_string a));
      Lwt.return_none
  | Failure f ->
      Dream.log "Failure happend: %s" f;
      Lwt.return_none
  | _ -> Lwt.return_none

let string_of_reply_reply_list
    (rrl : Redis_lwt.Client.reply list list Lwt.t option) =
  match rrl with
  | Some promise ->
      promise >|= fun r ->
      List.flatten r |> List.map Storage.Redis.json_of_reply
  | None -> Lwt.return [ `Null ]

let seed_from_fs () =
  let counter = ref 0 in
  let lines = Core.In_channel.read_lines "./lib/data" in
  lines
  |> log "lines read"
  |> Lwt_list.filter_map_p (fun id ->
         persist_all_tracks_from_artist_id id
         >|= logInfo
               ("saved "
               ^ string_of_int !counter
               ^ " of "
               ^ string_of_int
                   (counter := !counter + 1;
                    List.length lines)))

let test () =
  seed_from_fs () >|= List.map concat_json_strings >|= concat_json_strings
