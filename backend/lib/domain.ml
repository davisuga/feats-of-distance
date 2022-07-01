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
