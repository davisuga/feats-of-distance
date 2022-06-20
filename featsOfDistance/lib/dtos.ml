type profile = { name : string }
and purple_item = { uri : string; profile : profile }
and track_artists = { items : purple_item list }

and track =
  { saved : bool;
    uri : string;
    name : string;
    playcount : string;
    discNumber : int;
    trackNumber : int;
    contentRating : content_rating;
    duration : duration;
    playability : album_playability;
    artists : track_artists
  }

and domain =
  { queryArtistDiscographyAlbums : query_artist_discography_albums;
    queryAlbumTracks : query_album_tracks;
    queryArtistDiscographyOverview : query_artist_discography_overview;
    searchDesktop : search_desktop
  }
[@@deriving yojson, show]

and album_playability = { playable : bool }
and query_album_tracks = { dataQueryAlbumTracks : data_query_album_tracks }
and data_query_album_tracks = { album : album }
and album = { playability : album_playability; tracks : genres_class }
and genres_class = { totalCount : int; items : genres_item list }
and genres_item = { uid : string; track : track }
and content_rating = { label : label }
and label = string
and duration = { totalMilliseconds : int }

and query_artist_discography_albums =
  { dataQueryArtistDiscographyAlbums : data_query_artist_discography_albums }

and data_query_artist_discography_albums =
  { artist : data_query_artist_discography_albums_artist }

and data_query_artist_discography_albums_artist = { discography : purple_discography }
and purple_discography = { albums : purple_albums }
and purple_albums = { totalCount : int; items : fluffy_item list }
and fluffy_item = { releases : releases }
and releases = { items : releases_item list }

and releases_item =
  { id : string;
    uri : string;
    name : string;
    date : item_date;
    coverArt : cover_art;
    playability : item_playability;
    sharingInfo : sharing_info;
    tracks : all_class
  }

and cover_art = { sources : source list }
and source = { url : string; width : int option; height : int option }
and item_date = { year : int; isoString : string }
and item_playability = { playable : bool; reason : reason }
and reason = string
and sharing_info = { shareId : string; shareUrl : string }
and all_class = { totalCount : int }

and query_artist_discography_overview =
  { dataQueryArtistDiscographyOverview : data_query_artist_discography_overview }

and data_query_artist_discography_overview =
  { artist : data_query_artist_discography_overview_artist }

and data_query_artist_discography_overview_artist =
  { id : string; uri : string; profile : profile; discography : fluffy_discography }

and fluffy_discography =
  { albums : all_class; singles : all_class; compilations : all_class; all : all_class }

and search_desktop = { dataSearchDesktop : data_search_desktop }
and data_search_desktop = { searchV2 : search_v2 }

and search_v2 =
  { albums : search_v2_albums;
    artists : search_v2_artists;
    episodes : episodes;
    genres : genres_class;
    playlists : playlists;
    podcasts : podcasts;
    topResults : top_results;
    tracks : purple_tracks;
    users : users
  }

and search_v2_albums = { totalCount : int; items : tentacled_item list }
and tentacled_item = { data : purple_data }

and purple_data =
  { __andname : string;
    uri : string;
    name : string;
    artists : track_artists;
    coverArt : cover_art;
    date : data_date
  }

and data_date = { year : int }
and search_v2_artists = { totalCount : int; items : sticky_item list }
and sticky_item = { data : fluffy_data }

and fluffy_data =
  { __andname : string; uri : string; profile : profile; visuals : visuals }

and visuals = { avatarImage : cover_art }
and episodes = { totalCount : int; items : episodes_item list }
and episodes_item = { data : tentacled_data }

and tentacled_data =
  { __andname : string;
    uri : string;
    name : string;
    coverArt : cover_art;
    duration : duration;
    releaseDate : release_date;
    podcast : podcast_class;
    description : string;
    contentRating : content_rating
  }

and podcast_class =
  { uri : string;
    name : string;
    coverArt : cover_art;
    publisher : profile;
    mediaType : string;
    __andname : string option
  }

and release_date = { isoString : string; precision : string }
and playlists = { totalCount : int; items : featured_element list }
and featured_element = { data : featured_data }

and featured_data =
  { __andname : string;
    uri : string;
    name : string;
    description : string;
    images : images;
    owner : owner
  }

and images = { items : cover_art list }
and owner = { name : string; uri : string; username : string }
and podcasts = { totalCount : int; items : podcasts_item list }
and podcasts_item = { data : podcast_class }
and top_results = { items : indigo_item list; featured : featured_element list }
and indigo_item = { data : sticky_data }

and sticky_data =
  { __andname : string;
    uri : string;
    profile : profile option;
    visuals : visuals option;
    id : string option;
    name : string option;
    albumOfTrack : album_of_track option;
    artists : track_artists option;
    contentRating : content_rating option;
    duration : duration option;
    playability : album_playability option;
    description : string option;
    images : images option;
    owner : owner option;
    coverArt : cover_art option;
    date : data_date option;
    publisher : profile option;
    mediaType : string option
  }

and album_of_track = { uri : string; name : string; coverArt : cover_art; id : string }
and purple_tracks = { totalCount : int; items : indecent_item list }
and indecent_item = { data : indigo_data }

and indigo_data =
  { __andname : string;
    uri : string;
    id : string;
    name : string;
    albumOfTrack : album_of_track;
    artists : track_artists;
    contentRating : content_rating;
    duration : duration;
    playability : album_playability
  }

and users = { totalCount : int; items : users_item list }
and users_item = { data : indecent_data }

and indecent_data =
  { __andname : string;
    uri : string;
    id : string;
    displayName : string;
    username : string;
    image : image
  }
[@@deriving yojson, show]

and image = { smallImageUrl : string; largeImageUrl : string } [@@deriving yojson, show]
