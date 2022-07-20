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

exception ParseError of string * Yojson.Safe.t

module SearchDesktop = struct
  let operationName = "searchDesktop"
  let sha = "9542c8275ed5dd875f7ef4b2446da1cd796861f649fa4c244103364083830edd"

  open Printf

  module Result = struct
    type t = Dtos.search_desktop

    let from_yojson yo =
      try Dtos.search_desktop_of_yojson yo
      with Ppx_yojson_conv_lib__Yojson_conv.Of_yojson_error (exn, yojson) ->
        let e =
          sprintf "Failed parsing: %s. \n JSON: %s" (Printexc.to_string exn)
            (Yojson.Safe.pretty_to_string yojson)
        in
        failwith e

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
      { searchTerm = "drake"; offset = 0; limit = 10; numberOfTopResults = 10 }

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

let id_of_uri uri = List.nth (String.split_on_char ':' uri) 2

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
    ("connection", "keep-alive");
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
let default_token = new_token () |> Lwt_main.run
let current_token = ref default_token

let query_uri =
  Uri.of_string "https://api-partner.spotify.com/pathfinder/v1/query"

let rec fetchPage' ~headers uri =
  let* resp, body = Client.get ~headers uri in
  let code = resp |> Response.status |> Code.code_of_status in
  if code = 401 then (
    let* fresh_token = new_token () in
    current_token := fresh_token;

    let new_headers = make_header_with_token fresh_token in
    fetchPage' ~headers:new_headers uri)
  else Lwt.return (resp, body)

exception FetchError of string * string

let rec fetchPage ?(retry_count = 0) ~headers uri =
  try%lwt fetchPage' ~headers uri
  with e ->
    if retry_count < 500 then
      let%lwt () = Lwt_unix.sleep 10.1 in
      fetchPage ~retry_count:(retry_count + 1) ~headers uri
    else raise (FetchError (uri |> Uri.to_string, Printexc.to_string e))

let querySpotify ?token variables encode_variables decode_result operation_name
    sha =
  let* token =
    if Option.is_some token then Lwt.return (Option.get token) else new_token ()
  in
  let parsed_variables =
    variables |> encode_variables |> Yojson.Safe.to_string
  in
  let params =
    [
      ("operationName", operation_name);
      ("variables", parsed_variables);
      ("extensions", make_extension sha);
    ]
  in
  let headers = make_header_with_token token in
  let uri = Uri.add_query_params' query_uri params in
  let open Cache in
  let cache_key = operation_name ^ parsed_variables in
  FsCache.map_cases cache_key
    (fun cached_val ->
      cached_val |> Yojson.Safe.from_string |> decode_result |> Lwt.return)
    (fun _ ->
      fetchPage ~headers uri
      >>= string_of_body
      >|= Utils.tap (FsCache.set cache_key)
      >|= Yojson.Safe.from_string
      >|= decode_result)

let fetch_all_pages fetcher =
  let open Openapi.Paged in
  let%lwt res = fetcher 0l in

  let rec refetch current_items total offset =
    if total <% Int32.sub %> offset <= res.limit then
      let%lwt last_fetch = fetcher offset in
      Lwt.return (List.append current_items last_fetch.items)
    else
      let%lwt next_fetch = fetcher offset in

      refetch
        (List.append next_fetch.items current_items)
        total
        (offset <% Int32.add %> res.limit)
  in
  refetch res.items res.total res.limit

let get_artist_discography_all ?(token = !current_token) uri =
  let fetch_albums offset =
    Openapi.Artists_api.get_an_artists_albums
      ~include_groups:"single,appears_on,album,compilation" ~token ~offset
      ~id:(id_of_uri uri) ()
  in
  try%lwt fetch_all_pages fetch_albums
  with e ->
    failwith
      (Printf.sprintf "Failed to get artist discography: %s"
         (Printexc.to_string e))

let searchTerm ?(token = !current_token) term =
  let open SearchDesktop in
  querySpotify ~token
    { Variables.default with searchTerm = term }
    Variables.to_yojson Result.from_yojson operationName sha

let search_artists ?(token = !current_token) artist_name =
  let+ result = searchTerm ~token artist_name in
  result.data.searchV2.artists.items
  |> Array.map (fun (i : Dtos.artist_item) ->
         Domain.map_artist_of_artist_json i.data)

let getArtistOverview ?(token = !current_token) uri =
  let open ArtistOverview.Variables in
  let open ArtistOverview in
  querySpotify ~token { uri } Variables.to_yojson Result.from_yojson
    operationName sha

let get_album_tracks ?(token = !current_token) uri =
  let open AlbumTracks.Variables in
  let open AlbumTracks in
  querySpotify ~token
    { Variables.default with uri }
    Variables.to_yojson Result.from_yojson operationName sha

let get_album_ids_from_artist_overview
    (overview : Dtos.query_artist_discography_overview) =
  try
    overview.data.artist.discography.albums.items.(0).releases.items
    |> List.map (fun (album_data : ArtistDiscographyDto.releases_item) ->
           album_data.uri)
  with Invalid_argument _ ->
    Printf.sprintf "data.artist.discography.albums.items.(0) is null: %s"
      (ArtistDiscographyDto.show_artist_discography
         overview.data.artist.discography.albums)
    |> ignore;
    []

let get_singles_from_artist_overview
    (overview : Dtos.query_artist_discography_overview) =
  overview.data.artist.discography.singles.items
  |> List.map (fun (single : Dtos.discography_single_item) ->
         single.releases.items.(0).uri)

let bimap_to_list (f1 : 'a -> 'b) (f2 : 'a -> 'b) a = List.append (f1 a) (f2 a)

let get_albums_uris_by_artist_uri ?(token = !current_token) uid =
  get_artist_discography_all uid
  >|= List.map (fun (alb : Openapi.Simplified_album_object.t) -> alb.uri)
