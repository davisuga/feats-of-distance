(* Build with `ocamlbuild -pkg alcotest simple.byte` *)

(* A module with functions to test *)
open FeatsOfDistance.Storage

(* The tests *)
let test_create_feat_between_artists () =
  Alcotest.(check string)
    "same string"
    (Queries.create_feat_between_artists
       {
         name = "A simple song";
         authors = [ ("author a", "authora"); ("author b", "authorb") ];
         id = "songid";
       }
       "artista" "artistb")
    {|MERGE (artista)-[:FEATS_WITH {name:"A simple song", id:"songid"}]->(artistb)|}

let test_make_authors_features () =
  Alcotest.(check string)
    "same string"
    {|MERGE (artista)-[:FEATS_WITH {name:"A simple song", id:"songid"}]->(artistb)
MERGE (artista)-[:FEATS_WITH {name:"A simple song", id:"songid"}]->(artistc)
MERGE (artista)-[:FEATS_WITH {name:"A simple song", id:"songid"}]->(artistd)
MERGE (artistb)-[:FEATS_WITH {name:"A simple song", id:"songid"}]->(artistc)
MERGE (artistb)-[:FEATS_WITH {name:"A simple song", id:"songid"}]->(artistd)
MERGE (artistc)-[:FEATS_WITH {name:"A simple song", id:"songid"}]->(artistd)

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
         id = "songid";
       }
    |> String.concat "\n")

(* Run it *)
let () =
  let open Alcotest in
  run "Queries"
    [
      ( "Author",
        [
          test_case "create_feat_between_artists" `Quick
            test_create_feat_between_artists;
          test_case "make_authors_features" `Quick test_make_authors_features;
        ] );
    ]