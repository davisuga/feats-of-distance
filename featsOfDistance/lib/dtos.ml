include ArtistDiscographyDto

type album_playability = { playable : bool }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type duration = { totalMilliseconds : int }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type profile = { name : string }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type label = string [@@deriving yojson, show]

type content_rating = { label : label }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type artist_track_item = { uri : string; profile : profile }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type track_artists = { items : artist_track_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type track = {
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
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type genres_item = { uid : string; track : track }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type genres_class = { totalCount : int; items : genres_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type album = { playability : album_playability; tracks : genres_class }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type data_query_album_tracks = { album : album }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type query_album_tracks = { data : data_query_album_tracks }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type data_date = { year : int }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type fluffy_item = { releases : releases }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type releases = { items : releases_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type purple_albums = { totalCount : int; items : fluffy_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type purple_discography = { albums : purple_albums }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type data_query_artist_discography_albums_artist = {
  discography : purple_discography;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type data_query_artist_discography_albums = {
  artist : data_query_artist_discography_albums_artist;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type query_artist_discography_albums = {
  data : data_query_artist_discography_albums;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type all_class = { totalCount : int }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type item_playability = { playable : bool; reason : reason }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type item_date = { year : int; isoString : string }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type releases_item = {
  id : string;
  uri : string;
  name : string;
  date : item_date;
  coverArt : cover_art;
  playability : item_playability;
  sharingInfo : sharing_info;
  tracks : all_class;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type cover_art = { sources : source list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type visuals = {
  avatarImage : cover_art option; [@key "avatarImage"] [@yojson.default None]
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type source = {
  url : string;
  width : int option; [@yojson.option]
  height : int option; [@yojson.option]
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type reason = string

type sharing_info = { shareId : string; shareUrl : string }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type discography_single_item_release_item = {
  id : string;
  uri : string;
  name : string;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type discography_single_item_release = {
  items : discography_single_item_release_item array;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type discography_single_item = { releases : discography_single_item_release }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type discography_singles = {
  totalCount : int;
  items : discography_single_item list;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type fluffy_discography = {
  albums : ArtistDiscographyDto.artist_discography;
  singles : discography_singles;
      (* compilations : all_class; *)
      (* all : all_class; *)
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type data_query_artist_discography_overview_artist = {
  id : string;
  uri : string;
  profile : profile;
  discography : fluffy_discography;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type data_query_artist_discography_overview = {
  artist : data_query_artist_discography_overview_artist;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type query_artist_discography_overview = {
  data : data_query_artist_discography_overview;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type all_albums = ArtistDiscographyDto.artist_discography

type purple_data = {
  __typename : string;
  uri : string;
  name : string;
  artists : track_artists;
  coverArt : cover_art;
  date : data_date;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type tentacled_item = { data : purple_data }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type search_v2_albums = { totalCount : int; items : tentacled_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type artist_item_data = {
  __typename : string;
  uri : string;
  profile : profile;
  visuals : visuals;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type artist_item = { data : artist_item_data }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type search_v2_artists = { totalCount : int; items : artist_item array }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type release_date = { isoString : string; precision : string }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type podcast_class = {
  uri : string;
  name : string;
  coverArt : cover_art;
  publisher : profile;
  mediaType : string;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type tentacled_data = {
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
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type episodes_item = { data : tentacled_data }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type episodes = { totalCount : int; items : episodes_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type images = { items : cover_art list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type owner = { name : string; uri : string; username : string }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type featured_data = {
  __typename : string;
  uri : string;
  name : string;
  description : string;
  images : images;
  owner : owner;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type featured_element = { data : featured_data }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type playlists = { totalCount : int; items : featured_element list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type podcasts_item = { data : podcast_class }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type podcasts = { totalCount : int; items : podcasts_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type album_of_track = {
  uri : string;
  name : string;
  coverArt : cover_art;
  id : string;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type top_result_item_data = {
  __typename : string;
  uri : string;
  profile : profile option; [@yojson.option]
  visuals : visuals option; [@yojson.option]
      (* id : string option; [@yojson.option] *)
      (* name : string option; [@yojson.option]
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
         mediaType : string option; [@yojson.option]
         publisher : profile option; [@yojson.option] *)
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type top_results_item = { data : top_result_item_data }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type top_results = {
  items : top_results_item list;
  featured : featured_element list;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type indigo_data = {
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
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type indecent_item = { data : indigo_data }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type purple_tracks = { totalCount : int; items : indecent_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type image = { smallImageUrl : string option; largeImageUrl : string option }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type indecent_data = {
  __typename : string;
  uri : string;
  id : string;
  displayName : string;
  username : string;
  image : image;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type users_item = { data : indecent_data }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type users = { totalCount : int; items : users_item list }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type search_v2 = {
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
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type data_search_desktop = { searchV2 : search_v2 }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type search_desktop = { data : data_search_desktop }
[@@deriving yojson, show] [@@yojson.allow_extra_fields]

type domain = {
  queryArtistDiscographyAlbums : query_artist_discography_albums;
  queryAlbumTracks : query_album_tracks;
  queryArtistDiscographyOverview : query_artist_discography_overview;
  searchDesktop : search_desktop;
}
[@@deriving yojson, show] [@@yojson.allow_extra_fields]
