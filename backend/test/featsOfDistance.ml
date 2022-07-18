(* Build with `ocamlbuild -pkg alcotest simple.byte` *)

(* A module with functions to test *)
open FeatsOfDistanceLib
open Storage

let test_create_feat_between_artists () =
  Alcotest.(check string)
    "same string"
    {|MERGE (artista)-[:FEATS_WITH {name:\"A simple song\", uri:'songuri'}]->(artistb)|}
    (Queries.create_feat_between_artists
       {
         name = "A simple song";
         authors = [ ("author a", "authora"); ("author b", "authorb") ];
         uri = "songuri";
       }
       "artista" "artistb")

let test_make_authors_features () =
  Alcotest.(check string)
    "same string"
    {|MERGE (artista)-[:FEATS_WITH {name:\"A simple song\", uri:'songuri'}]->(artistb)
MERGE (artista)-[:FEATS_WITH {name:\"A simple song\", uri:'songuri'}]->(artistc)
MERGE (artista)-[:FEATS_WITH {name:\"A simple song\", uri:'songuri'}]->(artistd)
MERGE (artistb)-[:FEATS_WITH {name:\"A simple song\", uri:'songuri'}]->(artistc)
MERGE (artistb)-[:FEATS_WITH {name:\"A simple song\", uri:'songuri'}]->(artistd)
MERGE (artistc)-[:FEATS_WITH {name:\"A simple song\", uri:'songuri'}]->(artistd)

|}
    (Queries.make_authors_features_for_all
       [ "artista"; "artistb"; "artistc"; "artistd" ]
       {
         name = "A simple song";
         authors =
           [
             ("author a", "authora");
             ("author c", "authorc");
             ("author d", "authord");
             ("author b", "authorb");
           ];
         uri = "songuri";
       }
    |> String.concat "\n")

open Lwt.Infix

let test_get_artist_discography () =
  let _ =
    Http.get_artist_discography_all "spotify:artist:0Efm6O4zn2uSklFoUP7P8x"
    >|= List.map Openapi.Simplified_album_object.show
    >|= String.concat "\n"
    >|= Alcotest.(check string) "same string" "expected"
    |> Lwt_main.run
  in
  ()

let test_query_album_tracks () =
  Http.get_album_tracks "spotify:album:2ZBRkDrOktMqHA8z6Dhy0K"
  >|= Dtos.yojson_of_query_album_tracks
  >|= Yojson.Safe.to_string
  >|= Alcotest.(check string) "same string" "expected"
  |> Lwt_main.run

(* Run it *)
let () =
  let open Alcotest in
  run "Lib"
    [
      ( "Author Queries",
        [
          test_case "create_feat_between_artists" `Quick
            test_create_feat_between_artists;
          test_case "make_authors_features" `Quick test_make_authors_features;
        ] );
      ( "Artist integration",
        [
          test_case "get artist discography" `Slow test_get_artist_discography;
          test_case "get artist test_query_album_tracks" `Slow
            test_query_album_tracks;
        ] );
    ]
