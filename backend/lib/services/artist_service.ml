open Lwt.Infix

let get_one uri =
  Storage.Queries.get_artist_by_uri uri
  |> N4J.run_cypher_query
  >|= Utils.trace "Response %s"
  >|= Yojson.Safe.from_string
  >|= Yojson.Safe.Util.index 0
  >|= N4j_path_dto.node_of_yojson

let get_all_saved () =
  N4J.run_cypher_query Storage.Queries.Read.get_saved_artists
  >|= Utils.replace "[" ""
  >|= Utils.replace "]" ""
  >|= String.split_on_char ','
