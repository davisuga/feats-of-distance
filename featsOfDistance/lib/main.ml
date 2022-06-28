open Cohttp_lwt_unix
open Cohttp
open Lwt.Infix

let flip f x y = f y x

let uri =
  Uri.of_string
    "https://api-partner.spotify.com/pathfinder/v1/query?operationName=searchDesktop&variables=%7B%22searchTerm%22%3A%22drake%22%2C%22offset%22%3A0%2C%22limit%22%3A1%2C%22numberOfTopResults%22%3A5%7D&extensions=%7B%22persistedQuery%22%3A%7B%22version%22%3A1%2C%22sha256Hash%22%3A%229542c8275ed5dd875f7ef4b2446da1cd796861f649fa4c244103364083830edd%22%7D%7D"

open Lwt.Syntax

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

module Http = struct
  let base_headers =
    [
      ("content-type", "application/json;charset=UTF-8");
      ("accept", "application/json");
      ( "user-agent",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like \
         Gecko) Chrome/98.0.4758.102 Safari/537.36" );
      ("spotify-app-version", "1.1.81.88.g5e9024a5");
      ("app-platform", "WebPlayer");
      ("sec-ch-ua-platform", {|"Linux"|});
      ("origin", "https://open.spotify.com");
      ("sec-fetch-site", "same-site");
      ("sec-fetch-mode", "cors");
      ("sec-fetch-dest", "empty");
      ("referer", "https://open.spotify.com/");
      ("cookie", "sp_t=b0c70214f033a941dd00b09d173bba35");
      ("authority", "api-partner.spotify.com");
      ( "sec-ch-ua",
        {|" Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"|} );
      ("accept-language", "en");
      ("sec-ch-ua-mobile", "?0");
    ]

  let make_extension =
    Printf.sprintf "{\"persistedQuery\":{\"version\":1,\"sha256Hash\":\"%s\"}}"

  let uri = Uri.of_string "https://open.spotify.com/"

  let make_header_with_token jwt =
    Header.add_list (Header.init ())
      [ ("authorization", Printf.sprintf "Bearer %s" jwt) ]

  let token =
    "BQCBgcBCjj9PtkikMQw2wLEVSL8t6dVU6f0WTcB1Gp_Q5CburCDHr_UxagHwd3CQ3pctBPFRBw3Tuhipg0DiZn2lMoKYV3MJaJH2ned9be4-pu5o5qyD"

  let reg = "accessToken\":\"(.+?)\"" |> Re.Pcre.re |> Re.compile
  let string_of_body (_, body) = Cohttp_lwt.Body.to_string body

  let get_token_page () =
    let headers = Header.add_list (Header.init ()) base_headers in
    Client.get ~headers uri >>= string_of_body

  let extract_token body = Re.Pcre.extract ~rex:reg body |> (flip Array.get) 1
  let new_token () = get_token_page () >|= extract_token

  let query_uri =
    Uri.of_string "https://api-partner.spotify.com/pathfinder/v1/query"

  (* let trace msg any =
     Printf. msg;
     any *)
  let querySpotify ?token variables to_yojson from_yojson operation_name sha =
    let* token =
      if Option.is_some token then Lwt.return (Option.get token)
      else new_token ()
    in
    let parsed_variables = variables |> to_yojson |> Yojson.Safe.to_string in
    let params =
      [
        ("operationName", operation_name);
        ("variables", parsed_variables);
        ("extensions", make_extension sha);
      ]
    in
    let headers = make_header_with_token token in
    let uri = Uri.add_query_params' query_uri params in
    Printf.printf "uri: %s\n" (uri |> Uri.to_string);
    Client.get ~headers uri >>= string_of_body
    >|= (fun x ->
          print_string x;
          print_newline ();
          x)
    >|= Yojson.Safe.from_string >|= from_yojson

  let searchTerm ~token term =
    let open SearchDesktop in
    querySpotify ~token
      { Variables.default with searchTerm = term }
      Variables.to_yojson Result.from_yojson operationName sha

  let getArtistOverview ~token term =
    let open ArtistOverview.Variables in
    let open ArtistOverview in
    querySpotify ~token { uri = term } Variables.to_yojson Result.from_yojson
      operationName sha
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

let save_track_from_json ?(prefix = "") path =
  let track_json =
    Yojson.Safe.from_file (prefix ^ path)
    (* |> SearchDesktop.Result.from_yojson *)
    |> fun json ->
    try Dtos.genres_item_of_yojson json
    with Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error (e, t) ->
      failwith
        (Printf.sprintf "Failed to parse  \n %s \n %s"
           (* (Yojson.Safe.to_string json) *)
           (Yojson.Safe.to_string t)
           (Printexc.to_string e))
    (* |> get_ok_or (fun error ->
           failwith ("Couldn't parse search result. " ^ error)) *)
  in
  if List.length track_json.track.artists.items = 1 then None
  else
    let artist_ids =
      track_json.track.artists.items
      |> List.map (fun (artist_item : Dtos.artist_track_item) ->
             (artist_item.profile.name, artist_item.uri))
    in
    Some
      (Storage.Redis.run_cypher_query
         (Storage.Queries.create_song
            {
              authors = artist_ids;
              name = track_json.track.name;
              id = track_json.track.uri;
            }))

let save_artist_from_json ?(prefix = "") path =
  let artist_json =
    Yojson.Safe.from_file (prefix ^ path)
    (* |> SearchDesktop.Result.from_yojson *)
    |> (fun json ->
         try SearchDesktop.Result.from_yojson json
         with Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error (e, t) ->
           failwith
             (Printf.sprintf "Failed to parse  \n %s \n %s"
                (* (Yojson.Safe.to_string json) *)
                (Yojson.Safe.to_string t)
                (Printexc.to_string e)))
    |> get_first_artist_from_search_result
    (* |> get_ok_or (fun error ->
           failwith ("Couldn't parse search result. " ^ error)) *)
  in

  Storage.Redis.run_cypher_query
    (Storage.Queries.create_artist
       {
         img =
           (match artist_json.visuals.avatarImage with
           | Some avatar -> Some (avatar.sources |> List.hd).url
           | None -> None);
         name = artist_json.profile.name;
         id = artist_json.uri;
       })

let save_all_artists path =
  let _ = Storage.Redis.reset () |> Lwt_main.run in
  Sys.readdir path |> Array.to_seq
  (* |> (fun a -> Parany.Parmap.parmap a) *)
  |> Seq.map (save_artist_from_json ~prefix:path)

let save_all_tracks path =
  let _ = Storage.Redis.reset () |> Lwt_main.run in
  Sys.readdir path |> Array.to_seq
  (* |> Array.to_list *)
  (* |> (fun a -> Parany.Parmap.parmap a) *)
  |> Seq.filter_map (save_track_from_json ~prefix:path)

let iter_run = Seq.iter (fun prms -> Lwt_main.run prms |> ignore)

let test () =
  (* let _r =
       save_all_artists "./jsons/"
       |> Seq.iter (fun prms -> Lwt_main.run prms |> ignore)
     in *)
  let _r = save_all_tracks "./tracks/" |> iter_run in
  Lwt.return_unit
(* let* token = Http.new_token () in
   Printf.printf "New token: %s\n" token;
   let* searchResult = Http.searchTerm ~token "drake" in
   let open Yojson.Safe.Util in
   let artistId = (get_first_artist_from_search_result searchResult).uri in
   Printf.printf "Artist id: %s\n" artistId;

   let+ artistOverview = Http.getArtistOverview ~token artistId in
   Printf.printf "Artist name: %s\n" artistOverview.data.artist.profile.name;
   Printf.printf "Albums: %s"
     (artistOverview.data.artist.discography.albums.items
     |> Stdlib.List.map (fun item ->
             let open ArtistDiscographyDto in
             (item.releases.items |> Stdlib.List.hd).name)
     |> String.concat ", ") *)
