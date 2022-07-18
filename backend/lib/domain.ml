let map_song_from_json (track_json : Dtos.genres_item) =
  let open Models in
  let artists_name_and_uri =
    track_json.track.artists.items
    |> List.map (fun (artist_item : Dtos.artist_track_item) ->
           (artist_item.profile.name, artist_item.uri))
  in
  {
    authors = artists_name_and_uri;
    name = track_json.track.name;
    uri = track_json.track.uri;
  }

let list_max is_greater list =
  List.fold_right
    (fun item acc -> if is_greater item acc then item else acc)
    list (List.hd list)

let map_artist_of_artist_json (artist_json : Dtos.artist_item_data) =
  let open Models in
  let open ArtistDiscographyDto in
  {
    img =
      (match artist_json.visuals.avatarImage with
      | Some avatar ->
          Some
            (avatar.sources
            |> list_max (fun item_a item_b -> item_a.width < item_b.width))
              .url
      | None -> None);
    name = artist_json.profile.name;
    uri = artist_json.uri;
    description = None;
  }
