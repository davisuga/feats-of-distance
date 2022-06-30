open Cohttp_lwt_unix
open Cohttp
open Lwt.Infix
open Lwt.Syntax
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
  let sha = "3ea563e1d68f486d8df30f69de9dcedae74c77e684b889ba7408c589d30f7f2e"

  module Result = struct
    type t = Dtos.query_album_tracks

    let from_yojson = Dtos.query_album_tracks_of_yojson
    let to_yojson = Dtos.yojson_of_query_album_tracks
  end

  module Variables = struct
    type t = { uri : string; offset : int; limit : int }
    [@@deriving yojson, show]

    let default = { uri = ""; offset = 0; limit = 100 }
    let from_yojson = t_of_yojson
    let to_yojson = yojson_of_t
  end
end

let base_headers =
  [
    ("content-type", "application/json;charset=UTF-8");
    ("accept", "application/json");
    ( "user-agent",
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) \
       Chrome/98.0.4758.102 Safari/537.36" );
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

let reg = "accessToken\":\"(.+?)\"" |> Re.Pcre.re |> Re.compile
let string_of_body (_, body) = Cohttp_lwt.Body.to_string body

let get_token_page () =
  let headers = Header.add_list (Header.init ()) base_headers in
  Client.get ~headers uri >>= string_of_body

let extract_token body = Re.Pcre.extract ~rex:reg body |> (flip Array.get) 1
let new_token () = get_token_page () >|= extract_token

let query_uri =
  Uri.of_string "https://api-partner.spotify.com/pathfinder/v1/query"

let querySpotify ?token variables to_yojson from_yojson operation_name sha =
  let* token =
    if Option.is_some token then Lwt.return (Option.get token) else new_token ()
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
  Client.get ~headers uri
  >>= string_of_body
  >|= Yojson.Safe.from_string
  >|= from_yojson

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
