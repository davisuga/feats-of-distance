import { getToken } from './client'
import * as spotify from '../spotify-client'

export const artistApi = new spotify.ArtistsApi()
export const tracksApi = spotify.TracksApiFp()
export const searchApi = spotify.SearchApiFp()
