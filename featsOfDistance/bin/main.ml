(* let sas () =
     List.map
       (fun promise -> try Some (Lwt_main.run promise) with _ -> None)
       (FeatsOfDistance.Main.test ())

   let () = sas () |> ignore *)
(*
   let save_artist artist_id =
     FeatsOfDistance.Main.persist_all_tracks_from_artist_id artist_id
     |> Option.map Lwt_main.run
     |> ignore *)
let () = FeatsOfDistance.Server.start 8080