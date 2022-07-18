import { getToken } from './client'
import * as spotify from '../spotify-client'

export const artistApi = spotify.ArtistsApiFp()
export const tracksApi = spotify.TracksApiFp()
export const searchApi = spotify.SearchApiFp()
