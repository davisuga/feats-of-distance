open Cohttp_lwt_unix
open Cohttp
open Lwt.Infix

let flip f x y = f y x

let uri =
  Uri.of_string
    "https://api-partner.spotify.com/pathfinder/v1/query?operationName=searchDesktop&variables=%7B%22searchTerm%22%3A%22drake%22%2C%22offset%22%3A0%2C%22limit%22%3A1%2C%22numberOfTopResults%22%3A5%7D&extensions=%7B%22persistedQuery%22%3A%7B%22version%22%3A1%2C%22sha256Hash%22%3A%229542c8275ed5dd875f7ef4b2446da1cd796861f649fa4c244103364083830edd%22%7D%7D"

module Http = struct
  type search_variables =
    { searchTerm : string; offset : int; limit : int; numberOfTopResults : int }
  [@@deriving yojson, show]

  let base_headers =
    [ "content-type", "application/json;charset=UTF-8";
      "accept", "application/json";
      ( "user-agent",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) \
         Chrome/98.0.4758.102 Safari/537.36" );
      "spotify-app-version", "1.1.81.88.g5e9024a5";
      "app-platform", "WebPlayer";
      "sec-ch-ua-platform", {|"Linux"|};
      "origin", "https://open.spotify.com";
      "sec-fetch-site", "same-site";
      "sec-fetch-mode", "cors";
      "sec-fetch-dest", "empty";
      "referer", "https://open.spotify.com/";
      "cookie", "sp_t=b0c70214f033a941dd00b09d173bba35";
      "authority", "api-partner.spotify.com";
      "sec-ch-ua", {|" Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"|};
      "accept-language", "en";
      "sec-ch-ua-mobile", "?0"
    ]

  let extensions =
    "{\"persistedQuery\":{\"version\":1,\"sha256Hash\":\"9542c8275ed5dd875f7ef4b2446da1cd796861f649fa4c244103364083830edd\"}}"

  let uri = Uri.of_string "https://open.spotify.com/"

  let make_header_with_token jwt =
    Header.add_list (Header.init ()) [ "authorization", Printf.sprintf "Bearer %s" jwt ]

  let token =
    "BQCBgcBCjj9PtkikMQw2wLEVSL8t6dVU6f0WTcB1Gp_Q5CburCDHr_UxagHwd3CQ3pctBPFRBw3Tuhipg0DiZn2lMoKYV3MJaJH2ned9be4-pu5o5qyD"

  let reg = "accessToken\":\"(.+?)\"" |> Re.Pcre.re |> Re.compile
  let string_of_body (_, body) = Cohttp_lwt.Body.to_string body

  let get_token_page () =
    let headers = Header.add_list (Header.init ()) base_headers in
    Client.get ~headers uri >>= string_of_body

  let extract_token body = Re.Pcre.extract ~rex:reg body |> (flip Array.get) 1
  let new_token () = get_token_page () >|= extract_token
  let query_uri = Uri.of_string "https://api-partner.spotify.com/pathfinder/v1/query"

  open Lwt.Syntax

  type variables_get_album_tracks = { uri : string; offset : int; limit : int }

  let variables_default =
    { searchTerm = ""; offset = 0; limit = 1; numberOfTopResults = 5 }

  let searchTerm term =
    let* token = new_token () in
    let params =
      [ ( "variables",
          { variables_default with searchTerm = term }
          |> yojson_of_search_variables
          |> Yojson.Safe.to_string );
        "operationName", "searchDesktop";
        "extensions", extensions
      ]
    in
    let headers = make_header_with_token token in
    let uri = Uri.add_query_params' query_uri params in
    Client.get ~headers uri
    >>= string_of_body
    >|= Yojson.Safe.from_string
    >|= Dtos.search_desktop_of_yojson
end

let test () =
  let parsed = Lwt_main.run (Http.new_token ()) in
  let search = Http.searchTerm "drake" |> Lwt_main.run in
  Printf.printf "Parsed: %s\n" parsed;
  Printf.printf "Search: %s\n" (Dtos.show_search_desktop search)
