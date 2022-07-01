{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}

module QuickType
  ( ArtistResponse (..),
    ArtistResponseData (..),
    SearchV2 (..),
    Albums (..),
    AlbumsItem (..),
    PurpleData (..),
    DataArtists (..),
    PurpleItem (..),
    Profile (..),
    CoverArt (..),
    Source (..),
    Date (..),
    SearchV2Artists (..),
    FluffyItem (..),
    FluffyData (..),
    Visuals (..),
    Episodes (..),
    EpisodesItem (..),
    TentacledData (..),
    ContentRating (..),
    Duration (..),
    PodcastClass (..),
    ReleaseDate (..),
    Playlists (..),
    FeaturedElement (..),
    FeaturedData (..),
    Images (..),
    Owner (..),
    Podcasts (..),
    PodcastsItem (..),
    TopResults (..),
    TentacledItem (..),
    StickyData (..),
    AlbumOfTrack (..),
    Playability (..),
    Tracks (..),
    TracksItem (..),
    IndigoData (..),
    Users (..),
    UsersItem (..),
    IndecentData (..),
    Image (..),
    URI (..),
    PurpleTypename (..),
    Label (..),
    Type (..),
    MediaType (..),
    PodcastTypename (..),
    Precision (..),
    FluffyTypename (..),
    TentacledTypename (..),
    StickyTypename (..),
    IndigoTypename (..),
    decodeTopLevel,
  )
where

import Data.Aeson
import Data.Aeson.Types (emptyObject)
import Data.ByteString.Lazy (ByteString)
import Data.HashMap.Strict (HashMap)
import Data.Text (Text)

data ArtistResponse = ArtistResponse
  { artistResponseDataArtistResponse :: ArtistResponseData
  }
  deriving (Show)

data ArtistResponseData = ArtistResponseData
  { searchV2ArtistResponseData :: SearchV2
  }
  deriving (Show)

data SearchV2 = SearchV2
  { albumsSearchV2 :: Albums,
    artistsSearchV2 :: SearchV2Artists,
    episodesSearchV2 :: Episodes,
    genresSearchV2 :: Albums,
    playlistsSearchV2 :: Playlists,
    podcastsSearchV2 :: Podcasts,
    topResultsSearchV2 :: TopResults,
    tracksSearchV2 :: Tracks,
    usersSearchV2 :: Users
  }
  deriving (Show)

data Albums = Albums
  { totalCountAlbums :: Int,
    itemsAlbums :: [AlbumsItem]
  }
  deriving (Show)

data AlbumsItem = AlbumsItem
  { itemDataAlbumsItem :: PurpleData
  }
  deriving (Show)

data PurpleData = PurpleData
  { typenamePurpleData :: PurpleTypename,
    uriPurpleData :: Text,
    namePurpleData :: Text,
    artistsPurpleData :: DataArtists,
    coverArtPurpleData :: CoverArt,
    datePurpleData :: Date
  }
  deriving (Show)

data DataArtists = DataArtists
  { itemsDataArtists :: [PurpleItem]
  }
  deriving (Show)

data PurpleItem = PurpleItem
  { uriPurpleItem :: URI,
    profilePurpleItem :: Profile
  }
  deriving (Show)

data Profile = Profile
  { nameProfile :: Text
  }
  deriving (Show)

data URI
  = SpotifyArtist2AM4Ilv6UzW0UMRuqKtDgNURI
  deriving (Show)

data CoverArt = CoverArt
  { sourcesCoverArt :: [Source]
  }
  deriving (Show)

data Source = Source
  { urlSource :: Text,
    widthSource :: Maybe Int,
    heightSource :: Maybe Int
  }
  deriving (Show)

data Date = Date
  { yearDate :: Int
  }
  deriving (Show)

data PurpleTypename
  = AlbumPurpleTypename
  deriving (Show)

data SearchV2Artists = SearchV2Artists
  { totalCountSearchV2Artists :: Int,
    itemsSearchV2Artists :: [FluffyItem]
  }
  deriving (Show)

data FluffyItem = FluffyItem
  { itemDataFluffyItem :: FluffyData
  }
  deriving (Show)

data FluffyData = FluffyData
  { typenameFluffyData :: Text,
    uriFluffyData :: Text,
    profileFluffyData :: Profile,
    visualsFluffyData :: Visuals
  }
  deriving (Show)

data Visuals = Visuals
  { avatarImageVisuals :: Maybe CoverArt
  }
  deriving (Show)

data Episodes = Episodes
  { totalCountEpisodes :: Int,
    itemsEpisodes :: [EpisodesItem]
  }
  deriving (Show)

data EpisodesItem = EpisodesItem
  { itemDataEpisodesItem :: TentacledData
  }
  deriving (Show)

data TentacledData = TentacledData
  { typenameTentacledData :: FluffyTypename,
    uriTentacledData :: Text,
    nameTentacledData :: Text,
    coverArtTentacledData :: CoverArt,
    durationTentacledData :: Duration,
    releaseDateTentacledData :: ReleaseDate,
    podcastTentacledData :: PodcastClass,
    descriptionTentacledData :: Text,
    contentRatingTentacledData :: ContentRating
  }
  deriving (Show)

data ContentRating = ContentRating
  { labelContentRating :: Label
  }
  deriving (Show)

data Label
  = ExplicitLabel
  | NoneLabel
  deriving (Show)

data Duration = Duration
  { totalMillisecondsDuration :: Int
  }
  deriving (Show)

data PodcastClass = PodcastClass
  { uriPodcastClass :: Text,
    namePodcastClass :: Text,
    coverArtPodcastClass :: CoverArt,
    dataTypePodcastClass :: Type,
    publisherPodcastClass :: Profile,
    mediaTypePodcastClass :: MediaType,
    typenamePodcastClass :: Maybe PodcastTypename
  }
  deriving (Show)

data Type
  = TypePODCASTType
  deriving (Show)

data MediaType
  = AudioMediaType
  deriving (Show)

data PodcastTypename
  = PodcastPodcastTypename
  deriving (Show)

data ReleaseDate = ReleaseDate
  { isoStringReleaseDate :: Text,
    precisionReleaseDate :: Precision
  }
  deriving (Show)

data Precision
  = DayPrecision
  deriving (Show)

data FluffyTypename
  = EpisodeFluffyTypename
  deriving (Show)

data Playlists = Playlists
  { totalCountPlaylists :: Int,
    itemsPlaylists :: [FeaturedElement]
  }
  deriving (Show)

data FeaturedElement = FeaturedElement
  { itemDataFeaturedElement :: FeaturedData
  }
  deriving (Show)

data FeaturedData = FeaturedData
  { typenameFeaturedData :: TentacledTypename,
    uriFeaturedData :: Text,
    nameFeaturedData :: Text,
    descriptionFeaturedData :: Text,
    imagesFeaturedData :: Images,
    ownerFeaturedData :: Owner
  }
  deriving (Show)

data Images = Images
  { itemsImages :: [CoverArt]
  }
  deriving (Show)

data Owner = Owner
  { nameOwner :: Text,
    uriOwner :: Text,
    usernameOwner :: Text
  }
  deriving (Show)

data TentacledTypename
  = PlaylistTentacledTypename
  deriving (Show)

data Podcasts = Podcasts
  { totalCountPodcasts :: Int,
    itemsPodcasts :: [PodcastsItem]
  }
  deriving (Show)

data PodcastsItem = PodcastsItem
  { itemDataPodcastsItem :: PodcastClass
  }
  deriving (Show)

data TopResults = TopResults
  { itemsTopResults :: [TentacledItem],
    featuredTopResults :: [FeaturedElement]
  }
  deriving (Show)

data TentacledItem = TentacledItem
  { itemDataTentacledItem :: StickyData
  }
  deriving (Show)

data StickyData = StickyData
  { typenameStickyData :: Text,
    uriStickyData :: Text,
    profileStickyData :: Maybe Profile,
    visualsStickyData :: Maybe Visuals,
    dataIDStickyData :: Maybe Text,
    nameStickyData :: Maybe Text,
    albumOfTrackStickyData :: Maybe AlbumOfTrack,
    artistsStickyData :: Maybe DataArtists,
    contentRatingStickyData :: Maybe ContentRating,
    durationStickyData :: Maybe Duration,
    playabilityStickyData :: Maybe Playability,
    descriptionStickyData :: Maybe Text,
    imagesStickyData :: Maybe Images,
    ownerStickyData :: Maybe Owner,
    coverArtStickyData :: Maybe CoverArt,
    dateStickyData :: Maybe Date,
    dataTypeStickyData :: Maybe Type,
    publisherStickyData :: Maybe Profile,
    mediaTypeStickyData :: Maybe MediaType
  }
  deriving (Show)

data AlbumOfTrack = AlbumOfTrack
  { uriAlbumOfTrack :: Text,
    nameAlbumOfTrack :: Text,
    coverArtAlbumOfTrack :: CoverArt,
    albumOfTrackIDAlbumOfTrack :: Text
  }
  deriving (Show)

data Playability = Playability
  { playablePlayability :: Bool
  }
  deriving (Show)

data Tracks = Tracks
  { totalCountTracks :: Int,
    itemsTracks :: [TracksItem]
  }
  deriving (Show)

data TracksItem = TracksItem
  { itemDataTracksItem :: IndigoData
  }
  deriving (Show)

data IndigoData = IndigoData
  { typenameIndigoData :: StickyTypename,
    uriIndigoData :: Text,
    dataIDIndigoData :: Text,
    nameIndigoData :: Text,
    albumOfTrackIndigoData :: AlbumOfTrack,
    artistsIndigoData :: DataArtists,
    contentRatingIndigoData :: ContentRating,
    durationIndigoData :: Duration,
    playabilityIndigoData :: Playability
  }
  deriving (Show)

data StickyTypename
  = TrackStickyTypename
  deriving (Show)

data Users = Users
  { totalCountUsers :: Int,
    itemsUsers :: [UsersItem]
  }
  deriving (Show)

data UsersItem = UsersItem
  { itemDataUsersItem :: IndecentData
  }
  deriving (Show)

data IndecentData = IndecentData
  { typenameIndecentData :: IndigoTypename,
    uriIndecentData :: Text,
    dataIDIndecentData :: Text,
    displayNameIndecentData :: Text,
    usernameIndecentData :: Text,
    imageIndecentData :: Image
  }
  deriving (Show)

data Image = Image
  { smallImageURLImage :: Maybe Text,
    largeImageURLImage :: Maybe Text
  }
  deriving (Show)

data IndigoTypename
  = UserIndigoTypename
  deriving (Show)

decodeTopLevel :: ByteString -> Maybe ArtistResponse
decodeTopLevel = decode

instance ToJSON ArtistResponse where
  toJSON (ArtistResponse artistResponseDataArtistResponse) =
    object
      [ "data" .= artistResponseDataArtistResponse
      ]

instance FromJSON ArtistResponse where
  parseJSON (Object v) =
    ArtistResponse
      <$> v .: "data"

instance ToJSON ArtistResponseData where
  toJSON (ArtistResponseData searchV2ArtistResponseData) =
    object
      [ "searchV2" .= searchV2ArtistResponseData
      ]

instance FromJSON ArtistResponseData where
  parseJSON (Object v) =
    ArtistResponseData
      <$> v .: "searchV2"

instance ToJSON SearchV2 where
  toJSON (SearchV2 albumsSearchV2 artistsSearchV2 episodesSearchV2 genresSearchV2 playlistsSearchV2 podcastsSearchV2 topResultsSearchV2 tracksSearchV2 usersSearchV2) =
    object
      [ "albums" .= albumsSearchV2,
        "artists" .= artistsSearchV2,
        "episodes" .= episodesSearchV2,
        "genres" .= genresSearchV2,
        "playlists" .= playlistsSearchV2,
        "podcasts" .= podcastsSearchV2,
        "topResults" .= topResultsSearchV2,
        "tracks" .= tracksSearchV2,
        "users" .= usersSearchV2
      ]

instance FromJSON SearchV2 where
  parseJSON (Object v) =
    SearchV2
      <$> v .: "albums"
      <*> v .: "artists"
      <*> v .: "episodes"
      <*> v .: "genres"
      <*> v .: "playlists"
      <*> v .: "podcasts"
      <*> v .: "topResults"
      <*> v .: "tracks"
      <*> v .: "users"

instance ToJSON Albums where
  toJSON (Albums totalCountAlbums itemsAlbums) =
    object
      [ "totalCount" .= totalCountAlbums,
        "items" .= itemsAlbums
      ]

instance FromJSON Albums where
  parseJSON (Object v) =
    Albums
      <$> v .: "totalCount"
      <*> v .: "items"

instance ToJSON AlbumsItem where
  toJSON (AlbumsItem itemDataAlbumsItem) =
    object
      [ "data" .= itemDataAlbumsItem
      ]

instance FromJSON AlbumsItem where
  parseJSON (Object v) =
    AlbumsItem
      <$> v .: "data"

instance ToJSON PurpleData where
  toJSON (PurpleData typenamePurpleData uriPurpleData namePurpleData artistsPurpleData coverArtPurpleData datePurpleData) =
    object
      [ "__typename" .= typenamePurpleData,
        "uri" .= uriPurpleData,
        "name" .= namePurpleData,
        "artists" .= artistsPurpleData,
        "coverArt" .= coverArtPurpleData,
        "date" .= datePurpleData
      ]

instance FromJSON PurpleData where
  parseJSON (Object v) =
    PurpleData
      <$> v .: "__typename"
      <*> v .: "uri"
      <*> v .: "name"
      <*> v .: "artists"
      <*> v .: "coverArt"
      <*> v .: "date"

instance ToJSON DataArtists where
  toJSON (DataArtists itemsDataArtists) =
    object
      [ "items" .= itemsDataArtists
      ]

instance FromJSON DataArtists where
  parseJSON (Object v) =
    DataArtists
      <$> v .: "items"

instance ToJSON PurpleItem where
  toJSON (PurpleItem uriPurpleItem profilePurpleItem) =
    object
      [ "uri" .= uriPurpleItem,
        "profile" .= profilePurpleItem
      ]

instance FromJSON PurpleItem where
  parseJSON (Object v) =
    PurpleItem
      <$> v .: "uri"
      <*> v .: "profile"

instance ToJSON Profile where
  toJSON (Profile nameProfile) =
    object
      [ "name" .= nameProfile
      ]

instance FromJSON Profile where
  parseJSON (Object v) =
    Profile
      <$> v .: "name"

instance ToJSON URI where
  toJSON SpotifyArtist2AM4Ilv6UzW0UMRuqKtDgNURI = "spotify:artist:2AM4ilv6UzW0uMRuqKtDgN"

instance FromJSON URI where
  parseJSON = withText "URI" parseText
    where
      parseText "spotify:artist:2AM4ilv6UzW0uMRuqKtDgN" = return SpotifyArtist2AM4Ilv6UzW0UMRuqKtDgNURI

instance ToJSON CoverArt where
  toJSON (CoverArt sourcesCoverArt) =
    object
      [ "sources" .= sourcesCoverArt
      ]

instance FromJSON CoverArt where
  parseJSON (Object v) =
    CoverArt
      <$> v .: "sources"

instance ToJSON Source where
  toJSON (Source urlSource widthSource heightSource) =
    object
      [ "url" .= urlSource,
        "width" .= widthSource,
        "height" .= heightSource
      ]

instance FromJSON Source where
  parseJSON (Object v) =
    Source
      <$> v .: "url"
      <*> v .: "width"
      <*> v .: "height"

instance ToJSON Date where
  toJSON (Date yearDate) =
    object
      [ "year" .= yearDate
      ]

instance FromJSON Date where
  parseJSON (Object v) =
    Date
      <$> v .: "year"

instance ToJSON PurpleTypename where
  toJSON AlbumPurpleTypename = "Album"

instance FromJSON PurpleTypename where
  parseJSON = withText "PurpleTypename" parseText
    where
      parseText "Album" = return AlbumPurpleTypename

instance ToJSON SearchV2Artists where
  toJSON (SearchV2Artists totalCountSearchV2Artists itemsSearchV2Artists) =
    object
      [ "totalCount" .= totalCountSearchV2Artists,
        "items" .= itemsSearchV2Artists
      ]

instance FromJSON SearchV2Artists where
  parseJSON (Object v) =
    SearchV2Artists
      <$> v .: "totalCount"
      <*> v .: "items"

instance ToJSON FluffyItem where
  toJSON (FluffyItem itemDataFluffyItem) =
    object
      [ "data" .= itemDataFluffyItem
      ]

instance FromJSON FluffyItem where
  parseJSON (Object v) =
    FluffyItem
      <$> v .: "data"

instance ToJSON FluffyData where
  toJSON (FluffyData typenameFluffyData uriFluffyData profileFluffyData visualsFluffyData) =
    object
      [ "__typename" .= typenameFluffyData,
        "uri" .= uriFluffyData,
        "profile" .= profileFluffyData,
        "visuals" .= visualsFluffyData
      ]

instance FromJSON FluffyData where
  parseJSON (Object v) =
    FluffyData
      <$> v .: "__typename"
      <*> v .: "uri"
      <*> v .: "profile"
      <*> v .: "visuals"

instance ToJSON Visuals where
  toJSON (Visuals avatarImageVisuals) =
    object
      [ "avatarImage" .= avatarImageVisuals
      ]

instance FromJSON Visuals where
  parseJSON (Object v) =
    Visuals
      <$> v .: "avatarImage"

instance ToJSON Episodes where
  toJSON (Episodes totalCountEpisodes itemsEpisodes) =
    object
      [ "totalCount" .= totalCountEpisodes,
        "items" .= itemsEpisodes
      ]

instance FromJSON Episodes where
  parseJSON (Object v) =
    Episodes
      <$> v .: "totalCount"
      <*> v .: "items"

instance ToJSON EpisodesItem where
  toJSON (EpisodesItem itemDataEpisodesItem) =
    object
      [ "data" .= itemDataEpisodesItem
      ]

instance FromJSON EpisodesItem where
  parseJSON (Object v) =
    EpisodesItem
      <$> v .: "data"

instance ToJSON TentacledData where
  toJSON (TentacledData typenameTentacledData uriTentacledData nameTentacledData coverArtTentacledData durationTentacledData releaseDateTentacledData podcastTentacledData descriptionTentacledData contentRatingTentacledData) =
    object
      [ "__typename" .= typenameTentacledData,
        "uri" .= uriTentacledData,
        "name" .= nameTentacledData,
        "coverArt" .= coverArtTentacledData,
        "duration" .= durationTentacledData,
        "releaseDate" .= releaseDateTentacledData,
        "podcast" .= podcastTentacledData,
        "description" .= descriptionTentacledData,
        "contentRating" .= contentRatingTentacledData
      ]

instance FromJSON TentacledData where
  parseJSON (Object v) =
    TentacledData
      <$> v .: "__typename"
      <*> v .: "uri"
      <*> v .: "name"
      <*> v .: "coverArt"
      <*> v .: "duration"
      <*> v .: "releaseDate"
      <*> v .: "podcast"
      <*> v .: "description"
      <*> v .: "contentRating"

instance ToJSON ContentRating where
  toJSON (ContentRating labelContentRating) =
    object
      [ "label" .= labelContentRating
      ]

instance FromJSON ContentRating where
  parseJSON (Object v) =
    ContentRating
      <$> v .: "label"

instance ToJSON Label where
  toJSON ExplicitLabel = "EXPLICIT"
  toJSON NoneLabel = "NONE"

instance FromJSON Label where
  parseJSON = withText "Label" parseText
    where
      parseText "EXPLICIT" = return ExplicitLabel
      parseText "NONE" = return NoneLabel

instance ToJSON Duration where
  toJSON (Duration totalMillisecondsDuration) =
    object
      [ "totalMilliseconds" .= totalMillisecondsDuration
      ]

instance FromJSON Duration where
  parseJSON (Object v) =
    Duration
      <$> v .: "totalMilliseconds"

instance ToJSON PodcastClass where
  toJSON (PodcastClass uriPodcastClass namePodcastClass coverArtPodcastClass dataTypePodcastClass publisherPodcastClass mediaTypePodcastClass typenamePodcastClass) =
    object
      [ "uri" .= uriPodcastClass,
        "name" .= namePodcastClass,
        "coverArt" .= coverArtPodcastClass,
        "type" .= dataTypePodcastClass,
        "publisher" .= publisherPodcastClass,
        "mediaType" .= mediaTypePodcastClass,
        "__typename" .= typenamePodcastClass
      ]

instance FromJSON PodcastClass where
  parseJSON (Object v) =
    PodcastClass
      <$> v .: "uri"
      <*> v .: "name"
      <*> v .: "coverArt"
      <*> v .: "type"
      <*> v .: "publisher"
      <*> v .: "mediaType"
      <*> v .:? "__typename"

instance ToJSON Type where
  toJSON TypePODCASTType = "PODCAST"

instance FromJSON Type where
  parseJSON = withText "Type" parseText
    where
      parseText "PODCAST" = return TypePODCASTType

instance ToJSON MediaType where
  toJSON AudioMediaType = "AUDIO"

instance FromJSON MediaType where
  parseJSON = withText "MediaType" parseText
    where
      parseText "AUDIO" = return AudioMediaType

instance ToJSON PodcastTypename where
  toJSON PodcastPodcastTypename = "Podcast"

instance FromJSON PodcastTypename where
  parseJSON = withText "PodcastTypename" parseText
    where
      parseText "Podcast" = return PodcastPodcastTypename

instance ToJSON ReleaseDate where
  toJSON (ReleaseDate isoStringReleaseDate precisionReleaseDate) =
    object
      [ "isoString" .= isoStringReleaseDate,
        "precision" .= precisionReleaseDate
      ]

instance FromJSON ReleaseDate where
  parseJSON (Object v) =
    ReleaseDate
      <$> v .: "isoString"
      <*> v .: "precision"

instance ToJSON Precision where
  toJSON DayPrecision = "DAY"

instance FromJSON Precision where
  parseJSON = withText "Precision" parseText
    where
      parseText "DAY" = return DayPrecision

instance ToJSON FluffyTypename where
  toJSON EpisodeFluffyTypename = "Episode"

instance FromJSON FluffyTypename where
  parseJSON = withText "FluffyTypename" parseText
    where
      parseText "Episode" = return EpisodeFluffyTypename

instance ToJSON Playlists where
  toJSON (Playlists totalCountPlaylists itemsPlaylists) =
    object
      [ "totalCount" .= totalCountPlaylists,
        "items" .= itemsPlaylists
      ]

instance FromJSON Playlists where
  parseJSON (Object v) =
    Playlists
      <$> v .: "totalCount"
      <*> v .: "items"

instance ToJSON FeaturedElement where
  toJSON (FeaturedElement itemDataFeaturedElement) =
    object
      [ "data" .= itemDataFeaturedElement
      ]

instance FromJSON FeaturedElement where
  parseJSON (Object v) =
    FeaturedElement
      <$> v .: "data"

instance ToJSON FeaturedData where
  toJSON (FeaturedData typenameFeaturedData uriFeaturedData nameFeaturedData descriptionFeaturedData imagesFeaturedData ownerFeaturedData) =
    object
      [ "__typename" .= typenameFeaturedData,
        "uri" .= uriFeaturedData,
        "name" .= nameFeaturedData,
        "description" .= descriptionFeaturedData,
        "images" .= imagesFeaturedData,
        "owner" .= ownerFeaturedData
      ]

instance FromJSON FeaturedData where
  parseJSON (Object v) =
    FeaturedData
      <$> v .: "__typename"
      <*> v .: "uri"
      <*> v .: "name"
      <*> v .: "description"
      <*> v .: "images"
      <*> v .: "owner"

instance ToJSON Images where
  toJSON (Images itemsImages) =
    object
      [ "items" .= itemsImages
      ]

instance FromJSON Images where
  parseJSON (Object v) =
    Images
      <$> v .: "items"

instance ToJSON Owner where
  toJSON (Owner nameOwner uriOwner usernameOwner) =
    object
      [ "name" .= nameOwner,
        "uri" .= uriOwner,
        "username" .= usernameOwner
      ]

instance FromJSON Owner where
  parseJSON (Object v) =
    Owner
      <$> v .: "name"
      <*> v .: "uri"
      <*> v .: "username"

instance ToJSON TentacledTypename where
  toJSON PlaylistTentacledTypename = "Playlist"

instance FromJSON TentacledTypename where
  parseJSON = withText "TentacledTypename" parseText
    where
      parseText "Playlist" = return PlaylistTentacledTypename

instance ToJSON Podcasts where
  toJSON (Podcasts totalCountPodcasts itemsPodcasts) =
    object
      [ "totalCount" .= totalCountPodcasts,
        "items" .= itemsPodcasts
      ]

instance FromJSON Podcasts where
  parseJSON (Object v) =
    Podcasts
      <$> v .: "totalCount"
      <*> v .: "items"

instance ToJSON PodcastsItem where
  toJSON (PodcastsItem itemDataPodcastsItem) =
    object
      [ "data" .= itemDataPodcastsItem
      ]

instance FromJSON PodcastsItem where
  parseJSON (Object v) =
    PodcastsItem
      <$> v .: "data"

instance ToJSON TopResults where
  toJSON (TopResults itemsTopResults featuredTopResults) =
    object
      [ "items" .= itemsTopResults,
        "featured" .= featuredTopResults
      ]

instance FromJSON TopResults where
  parseJSON (Object v) =
    TopResults
      <$> v .: "items"
      <*> v .: "featured"

instance ToJSON TentacledItem where
  toJSON (TentacledItem itemDataTentacledItem) =
    object
      [ "data" .= itemDataTentacledItem
      ]

instance FromJSON TentacledItem where
  parseJSON (Object v) =
    TentacledItem
      <$> v .: "data"

instance ToJSON StickyData where
  toJSON (StickyData typenameStickyData uriStickyData profileStickyData visualsStickyData dataIDStickyData nameStickyData albumOfTrackStickyData artistsStickyData contentRatingStickyData durationStickyData playabilityStickyData descriptionStickyData imagesStickyData ownerStickyData coverArtStickyData dateStickyData dataTypeStickyData publisherStickyData mediaTypeStickyData) =
    object
      [ "__typename" .= typenameStickyData,
        "uri" .= uriStickyData,
        "profile" .= profileStickyData,
        "visuals" .= visualsStickyData,
        "id" .= dataIDStickyData,
        "name" .= nameStickyData,
        "albumOfTrack" .= albumOfTrackStickyData,
        "artists" .= artistsStickyData,
        "contentRating" .= contentRatingStickyData,
        "duration" .= durationStickyData,
        "playability" .= playabilityStickyData,
        "description" .= descriptionStickyData,
        "images" .= imagesStickyData,
        "owner" .= ownerStickyData,
        "coverArt" .= coverArtStickyData,
        "date" .= dateStickyData,
        "type" .= dataTypeStickyData,
        "publisher" .= publisherStickyData,
        "mediaType" .= mediaTypeStickyData
      ]

instance FromJSON StickyData where
  parseJSON (Object v) =
    StickyData
      <$> v .: "__typename"
      <*> v .: "uri"
      <*> v .:? "profile"
      <*> v .:? "visuals"
      <*> v .:? "id"
      <*> v .:? "name"
      <*> v .:? "albumOfTrack"
      <*> v .:? "artists"
      <*> v .:? "contentRating"
      <*> v .:? "duration"
      <*> v .:? "playability"
      <*> v .:? "description"
      <*> v .:? "images"
      <*> v .:? "owner"
      <*> v .:? "coverArt"
      <*> v .:? "date"
      <*> v .:? "type"
      <*> v .:? "publisher"
      <*> v .:? "mediaType"

instance ToJSON AlbumOfTrack where
  toJSON (AlbumOfTrack uriAlbumOfTrack nameAlbumOfTrack coverArtAlbumOfTrack albumOfTrackIDAlbumOfTrack) =
    object
      [ "uri" .= uriAlbumOfTrack,
        "name" .= nameAlbumOfTrack,
        "coverArt" .= coverArtAlbumOfTrack,
        "id" .= albumOfTrackIDAlbumOfTrack
      ]

instance FromJSON AlbumOfTrack where
  parseJSON (Object v) =
    AlbumOfTrack
      <$> v .: "uri"
      <*> v .: "name"
      <*> v .: "coverArt"
      <*> v .: "id"

instance ToJSON Playability where
  toJSON (Playability playablePlayability) =
    object
      [ "playable" .= playablePlayability
      ]

instance FromJSON Playability where
  parseJSON (Object v) =
    Playability
      <$> v .: "playable"

instance ToJSON Tracks where
  toJSON (Tracks totalCountTracks itemsTracks) =
    object
      [ "totalCount" .= totalCountTracks,
        "items" .= itemsTracks
      ]

instance FromJSON Tracks where
  parseJSON (Object v) =
    Tracks
      <$> v .: "totalCount"
      <*> v .: "items"

instance ToJSON TracksItem where
  toJSON (TracksItem itemDataTracksItem) =
    object
      [ "data" .= itemDataTracksItem
      ]

instance FromJSON TracksItem where
  parseJSON (Object v) =
    TracksItem
      <$> v .: "data"

instance ToJSON IndigoData where
  toJSON (IndigoData typenameIndigoData uriIndigoData dataIDIndigoData nameIndigoData albumOfTrackIndigoData artistsIndigoData contentRatingIndigoData durationIndigoData playabilityIndigoData) =
    object
      [ "__typename" .= typenameIndigoData,
        "uri" .= uriIndigoData,
        "id" .= dataIDIndigoData,
        "name" .= nameIndigoData,
        "albumOfTrack" .= albumOfTrackIndigoData,
        "artists" .= artistsIndigoData,
        "contentRating" .= contentRatingIndigoData,
        "duration" .= durationIndigoData,
        "playability" .= playabilityIndigoData
      ]

instance FromJSON IndigoData where
  parseJSON (Object v) =
    IndigoData
      <$> v .: "__typename"
      <*> v .: "uri"
      <*> v .: "id"
      <*> v .: "name"
      <*> v .: "albumOfTrack"
      <*> v .: "artists"
      <*> v .: "contentRating"
      <*> v .: "duration"
      <*> v .: "playability"

instance ToJSON StickyTypename where
  toJSON TrackStickyTypename = "Track"

instance FromJSON StickyTypename where
  parseJSON = withText "StickyTypename" parseText
    where
      parseText "Track" = return TrackStickyTypename

instance ToJSON Users where
  toJSON (Users totalCountUsers itemsUsers) =
    object
      [ "totalCount" .= totalCountUsers,
        "items" .= itemsUsers
      ]

instance FromJSON Users where
  parseJSON (Object v) =
    Users
      <$> v .: "totalCount"
      <*> v .: "items"

instance ToJSON UsersItem where
  toJSON (UsersItem itemDataUsersItem) =
    object
      [ "data" .= itemDataUsersItem
      ]

instance FromJSON UsersItem where
  parseJSON (Object v) =
    UsersItem
      <$> v .: "data"

instance ToJSON IndecentData where
  toJSON (IndecentData typenameIndecentData uriIndecentData dataIDIndecentData displayNameIndecentData usernameIndecentData imageIndecentData) =
    object
      [ "__typename" .= typenameIndecentData,
        "uri" .= uriIndecentData,
        "id" .= dataIDIndecentData,
        "displayName" .= displayNameIndecentData,
        "username" .= usernameIndecentData,
        "image" .= imageIndecentData
      ]

instance FromJSON IndecentData where
  parseJSON (Object v) =
    IndecentData
      <$> v .: "__typename"
      <*> v .: "uri"
      <*> v .: "id"
      <*> v .: "displayName"
      <*> v .: "username"
      <*> v .: "image"

instance ToJSON Image where
  toJSON (Image smallImageURLImage largeImageURLImage) =
    object
      [ "smallImageUrl" .= smallImageURLImage,
        "largeImageUrl" .= largeImageURLImage
      ]

instance FromJSON Image where
  parseJSON (Object v) =
    Image
      <$> v .: "smallImageUrl"
      <*> v .: "largeImageUrl"

instance ToJSON IndigoTypename where
  toJSON UserIndigoTypename = "User"

instance FromJSON IndigoTypename where
  parseJSON = withText "IndigoTypename" parseText
    where
      parseText "User" = return UserIndigoTypename
