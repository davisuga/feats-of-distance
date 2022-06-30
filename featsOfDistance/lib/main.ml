open Utils
open Http

let log m anything =
  print_string m;
  print_newline ();
  anything

module List = struct
  module Pipe = struct
    let nth = flip List.nth
  end

  include List
end

let get_first_artist_from_search_result (searchResult : Dtos.search_desktop) =
  (searchResult.data.searchV2.artists.items |> List.Pipe.nth 0).data

open! Printf

let get_ok_or fn result =
  match result with Ok something -> something | Error e -> fn e

let try_parse_json_with ?(prefix = "") parse_yojson path =
  try parse_yojson (Yojson.Safe.from_file (prefix ^ path))
  with Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error (e, t) ->
    failwith
      (Printf.sprintf "Failed to parse  \n %s \n %s" (Yojson.Safe.to_string t)
         (Printexc.to_string e))

let map_song_from_json (track_json : Dtos.genres_item) =
  let open Models in
  let artist_ids =
    track_json.track.artists.items
    |> List.map (fun (artist_item : Dtos.artist_track_item) ->
           (artist_item.profile.name, artist_item.uri))
  in
  {
    authors = artist_ids;
    name = track_json.track.name;
    id = track_json.track.uri;
  }

let map_artist_of_artist_json (artist_json : Dtos.artist_item_data) =
  let open Models in
  {
    img =
      (match artist_json.visuals.avatarImage with
      | Some avatar -> Some (avatar.sources |> List.hd).url
      | None -> None);
    name = artist_json.profile.name;
    id = artist_json.uri;
  }

let save_track_from_json (track_json : Dtos.genres_item) =
  if List.length track_json.track.artists.items < 2 then None
  else
    track_json
    |> map_song_from_json
    |> log "mapping song from json"
    |> Storage.Queries.create_song
    |> Storage.Redis.run_cypher_query
    |> log "cypher query run"
    |> Option.some

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
  try_parse_json_with SearchDesktop.Result.from_yojson ~prefix path
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
let id a = a;;

Parmap.debugging true

let persist_album_tracks_result (album_tracks : Dtos.query_album_tracks) =
  album_tracks.data.album.tracks.items
  |> List.filter_map save_track_from_json
  |> log "persist_album_tracks_result"
  |> Lwt_list.map_s id

let get_and_persist_album_tracks album_id =
  get_album_tracks album_id
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

let persist_all_tracks_from_artist_id artist_id =
  artist_id
  |> Http.get_albums_and_singles_by_artist_id
  |> log ("got albums and singles by" ^ artist_id)
  (* >|= Lwt_stream.of_list *)
  >>= Lwt_list.map_s get_and_persist_album_tracks

let persist_all_tracks_from_artist_ids_p artist_ids =
  artist_ids
  |> parmap Http.get_albums_and_singles_by_artist_id
  |> Lwt_list.map_s id
  >|= parmap (parmap_lwt get_album_tracks)
  >>= Lwt_list.map_s id
  >>= Lwt_list.map_s (Lwt_list.map_s persist_album_tracks_result)

let test () =
  Core.In_channel.read_lines "./lib/data"
  |> log "lines read"
  |> List.map persist_all_tracks_from_artist_id
  |> Lwt_list.map_s id
