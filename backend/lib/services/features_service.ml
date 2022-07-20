open Lwt.Infix

let features_of_distance ~limit from to' =
  Storage.Queries.create_shortest_path
    ~limit:(Option.value limit ~default:2)
    from to'
  |> N4J.run_cypher_query
  >|= Yojson.Safe.from_string
  >|= N4j_path_dto.path_response_dto_of_yojson
  >|= N4j_path_dto.relations_of_response
