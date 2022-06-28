open Utils

module type SpotifyQuery = sig
  val operationName : string

  module Result : sig
    type t

    val from_yojson : Yojson.Safe.t -> t
    val to_yojson : t -> Yojson.Safe.t
  end

  module Variables : sig
    type t

    val create : string -> t
    val pp : Format.formatter -> t -> unit
    val show : t -> string
    val from_yojson : Yojson.Safe.t -> t
    val to_yojson : t -> Yojson.Safe.t
  end
end

module SearchDesktop = struct
  let operationName = "searchDesktop"
  let sha = "9542c8275ed5dd875f7ef4b2446da1cd796861f649fa4c244103364083830edd"

  module Result = struct
    type t = Dtos.search_desktop

    let from_yojson = Dtos.search_desktop_of_yojson
    let to_yojson = Dtos.yojson_of_search_desktop
  end

  module Variables = struct
    type t = {
      searchTerm : string;
      offset : int;
      limit : int;
      numberOfTopResults : int;
    }
    [@@deriving yojson, show]

    let default =
      { searchTerm = "drake"; offset = 0; limit = 1; numberOfTopResults = 5 }

    let from_yojson = t_of_yojson
    let to_yojson = yojson_of_t
  end
end

module ArtistOverview = struct
  let operationName = "queryArtistOverview"
  let sha = "433e28d1e949372d3ca3aa6c47975cff428b5dc37b12f5325d9213accadf770a"

  module Result = struct
    type t = Dtos.query_artist_discography_overview

    let from_yojson = Dtos.query_artist_discography_overview_of_yojson
    let to_yojson = Dtos.yojson_of_query_artist_discography_overview
  end

  module Variables = struct
    type t = { uri : string } [@@deriving yojson, show]

    let default = { uri = "" }
    let from_yojson = t_of_yojson
    let to_yojson = yojson_of_t
  end
end

module AlbumTracks = struct
  let operationName = "queryAlbumTracks"

  module Result = struct
    type t = Dtos.query_album_tracks

    let from_yojson = Dtos.query_album_tracks_of_yojson
    let to_yojson = Dtos.yojson_of_query_album_tracks
  end

  module Variables = struct
    type t = { uri : string; offset : int; limit : int }
    [@@deriving yojson, show]

    let default = { uri = ""; offset = 0; limit = 100 }
    let from_yojson = yojson_of_t
    let to_yojson = t_of_yojson
  end
end

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

let save_track_from_json ?(prefix = "") path =
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
  read_dir path |> Seq.filter_map (save_track_from_json ~prefix:path)

let iter_run = Seq.iter (fun prms -> Lwt_main.run prms |> ignore)

let test () =
  let _ = Storage.Redis.reset () |> Lwt_main.run in

  (* let _r =
       save_all_artists "./jsons/"
       |> Seq.iter (fun prms -> Lwt_main.run prms |> ignore)
     in *)
  let _r = save_all_tracks "./tracks/" |> iter_run in
  Lwt.return_unit
