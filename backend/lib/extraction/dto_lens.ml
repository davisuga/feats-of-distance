let get_first_artist_from_search_result (searchResult : Dtos.search_desktop) =
  searchResult.data.searchV2.artists.items.(0).data

let get_tracks_of_album_query_result (album_tracks : Dtos.query_album_tracks) =
  album_tracks.data.album.tracks.items

let get_artists_of_track (track_json : Dtos.genres_item) =
  track_json.track.artists.items
