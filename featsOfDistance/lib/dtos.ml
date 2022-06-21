type profile = { name : string } [@@yojson.allow_extra_fields]

and purple_item = { uri : string; profile : profile }
[@@yojson.allow_extra_fields]

and track_artists = { items : purple_item list } [@@yojson.allow_extra_fields]

and track = {
  saved : bool;
  uri : string;
  name : string;
  playcount : string;
  discNumber : int;
  trackNumber : int;
  contentRating : content_rating;
  duration : duration;
  playability : album_playability;
  artists : track_artists;
}
[@@yojson.allow_extra_fields]

and domain = {
  queryArtistDiscographyAlbums : query_artist_discography_albums;
  queryAlbumTracks : query_album_tracks;
  queryArtistDiscographyOverview : query_artist_discography_overview;
  searchDesktop : search_desktop;
}
[@@yojson.allow_extra_fields] [@@deriving yojson, show]

and album_playability = { playable : bool } [@@yojson.allow_extra_fields]

and query_album_tracks = { data : data_query_album_tracks }
[@@yojson.allow_extra_fields]

and data_query_album_tracks = { album : album } [@@yojson.allow_extra_fields]

and album = { playability : album_playability; tracks : genres_class }
[@@yojson.allow_extra_fields]

and genres_class = { totalCount : int; items : genres_item list }
[@@yojson.allow_extra_fields]

and genres_item = { uid : string; track : track } [@@yojson.allow_extra_fields]
and content_rating = { label : label } [@@yojson.allow_extra_fields]
and label = string
and duration = { totalMilliseconds : int } [@@yojson.allow_extra_fields]

and query_artist_discography_albums = {
  data : data_query_artist_discography_albums;
}
[@@yojson.allow_extra_fields]

and data_query_artist_discography_albums = {
  artist : data_query_artist_discography_albums_artist;
}
[@@yojson.allow_extra_fields]

and data_query_artist_discography_albums_artist = {
  discography : purple_discography;
}
[@@yojson.allow_extra_fields]

and purple_discography = { albums : purple_albums }
[@@yojson.allow_extra_fields]

and purple_albums = { totalCount : int; items : fluffy_item list }
[@@yojson.allow_extra_fields]

and fluffy_item = { releases : releases } [@@yojson.allow_extra_fields]
and releases = { items : releases_item list } [@@yojson.allow_extra_fields]

and releases_item = {
  id : string;
  uri : string;
  name : string;
  date : item_date;
  coverArt : cover_art;
  playability : item_playability;
  sharingInfo : sharing_info;
  tracks : all_class;
}
[@@yojson.allow_extra_fields]

and cover_art = { sources : source list } [@@yojson.allow_extra_fields]

and source = {
  url : string;
  width : int option; [@yojson.option]
  height : int option; [@yojson.option]
}
[@@yojson.allow_extra_fields]

and item_date = { year : int; isoString : string } [@@yojson.allow_extra_fields]

and item_playability = { playable : bool; reason : reason }
[@@yojson.allow_extra_fields]

and reason = string

and sharing_info = { shareId : string; shareUrl : string }
[@@yojson.allow_extra_fields]

and all_class = { totalCount : int } [@@yojson.allow_extra_fields]

and query_artist_discography_overview = {
  data : data_query_artist_discography_overview;
}
[@@yojson.allow_extra_fields]

and data_query_artist_discography_overview = {
  artist : data_query_artist_discography_overview_artist;
}
[@@yojson.allow_extra_fields]

and data_query_artist_discography_overview_artist = {
  id : string;
  uri : string;
  profile : profile;
  discography : fluffy_discography;
}
[@@yojson.allow_extra_fields]

and fluffy_discography = {
  albums : all_class;
  singles : all_class;
  compilations : all_class;
  all : all_class;
}
[@@yojson.allow_extra_fields]

and search_desktop = { data : data_search_desktop }
[@@yojson.allow_extra_fields]

and data_search_desktop = { searchV2 : search_v2 } [@@yojson.allow_extra_fields]

and search_v2 = {
  (* albums : search_v2_albums; *)
  artists : search_v2_artists;
      (* episodes : episodes; *)
      (* genres : genres_class; *)
      (* playlists : playlists; *)
      (* podcasts : podcasts; *)
      (* topResults : top_results; *)
      (* tracks : purple_tracks; *)
      (* users : users; *)
}
[@@yojson.allow_extra_fields]

and search_v2_albums = { totalCount : int; items : tentacled_item list }
[@@yojson.allow_extra_fields]

and tentacled_item = { data : purple_data } [@@yojson.allow_extra_fields]

and purple_data = {
  __typename : string;
  uri : string;
  name : string;
  artists : track_artists;
  coverArt : cover_art;
  date : data_date;
}
[@@yojson.allow_extra_fields]

and data_date = { year : int } [@@yojson.allow_extra_fields]

and search_v2_artists = { totalCount : int; items : artist_item list }
[@@yojson.allow_extra_fields]

and artist_item = { data : artist_item_data } [@@yojson.allow_extra_fields]

and artist_item_data = {
  __typename : string;
  uri : string;
  profile : profile;
  visuals : visuals;
}
[@@yojson.allow_extra_fields]

and visuals = { avatarImage : cover_art } [@@yojson.allow_extra_fields]

and episodes = { totalCount : int; items : episodes_item list }
[@@yojson.allow_extra_fields]

and episodes_item = { data : tentacled_data } [@@yojson.allow_extra_fields]

and tentacled_data = {
  __typename : string;
  uri : string;
  name : string;
  coverArt : cover_art;
  duration : duration;
  releaseDate : release_date;
  podcast : podcast_class;
  description : string;
  contentRating : content_rating;
}
[@@yojson.allow_extra_fields]

and podcast_class = {
  uri : string;
  name : string;
  coverArt : cover_art;
  publisher : profile;
  mediaType : string;
}
[@@yojson.allow_extra_fields]

and release_date = { isoString : string; precision : string }
[@@yojson.allow_extra_fields]

and playlists = { totalCount : int; items : featured_element list }
[@@yojson.allow_extra_fields]

and featured_element = { data : featured_data } [@@yojson.allow_extra_fields]

and featured_data = {
  __typename : string;
  uri : string;
  name : string;
  description : string;
  images : images;
  owner : owner;
}
[@@yojson.allow_extra_fields]

and images = { items : cover_art list } [@@yojson.allow_extra_fields]

and owner = { name : string; uri : string; username : string }
[@@yojson.allow_extra_fields]

and podcasts = { totalCount : int; items : podcasts_item list }
[@@yojson.allow_extra_fields]

and podcasts_item = { data : podcast_class } [@@yojson.allow_extra_fields]

and top_results = { items : indigo_item list; featured : featured_element list }
[@@yojson.allow_extra_fields]

and indigo_item = { data : sticky_data } [@@yojson.allow_extra_fields]

and sticky_data = {
  __typename : string;
  uri : string;
  profile : profile option; [@yojson.option]
  visuals : visuals option; [@yojson.option]
  id : string option; [@yojson.option]
  name : string option; [@yojson.option]
  albumOfTrack : album_of_track option; [@yojson.option]
  artists : track_artists option; [@yojson.option]
  contentRating : content_rating option; [@yojson.option]
  duration : duration option; [@yojson.option]
  playability : album_playability option; [@yojson.option]
  description : string option; [@yojson.option]
  images : images option; [@yojson.option]
  owner : owner option; [@yojson.option]
  coverArt : cover_art option; [@yojson.option]
  date : data_date option; [@yojson.option]
  publisher : profile option; [@yojson.option]
  mediaType : string option; [@yojson.option]
}
[@@yojson.allow_extra_fields]

and album_of_track = {
  uri : string;
  name : string;
  coverArt : cover_art;
  id : string;
}
[@@yojson.allow_extra_fields]

and purple_tracks = { totalCount : int; items : indecent_item list }
[@@yojson.allow_extra_fields]

and indecent_item = { data : indigo_data } [@@yojson.allow_extra_fields]

and indigo_data = {
  __typename : string;
  uri : string;
  id : string;
  name : string;
  albumOfTrack : album_of_track;
  artists : track_artists;
  contentRating : content_rating;
  duration : duration;
  playability : album_playability;
}
[@@yojson.allow_extra_fields]

and users = { totalCount : int; items : users_item list }
[@@yojson.allow_extra_fields]

and users_item = { data : indecent_data } [@@yojson.allow_extra_fields]

and indecent_data = {
  __typename : string;
  uri : string;
  id : string;
  displayName : string;
  username : string;
  image : image;
}
[@@yojson.allow_extra_fields]

and image = { smallImageUrl : string; largeImageUrl : string }
[@@yojson.allow_extra_fields]
