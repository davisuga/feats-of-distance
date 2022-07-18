import axios from 'axios'
import { tap } from '../utils/tap'

const client = axios.create({
  baseURL: process.env.REACT_BACKEND_URL,
})
const spotifyClient = axios.create({
  baseURL: 'https://api.spotify.com/v1/',
})
console.log('env', process.env)
export const fetchSpotifyToken = async () =>
  (await client.get<string>('token')).data

export const getToken = () => {
  if (typeof window === 'undefined') {
    return fetchSpotifyToken()
  }
  const localToken = localStorage.getItem('token')
  if (!localToken) {
    return updateToken()
  }
  return Promise.resolve(localToken)
}
const setToken = (token: string) => localStorage.setItem('token', token)

const updateToken = () =>
  fetchSpotifyToken()
    .then(tap(setToken))
    .then(tap((x) => console.log('updating token')))

axios.interceptors.request.use(
  async function (config) {
    const token = await getToken()
    console.log('the damn token:', token)
    // Faz alguma coisa antes da requisição ser enviada
    return {
      ...config,
      headers: {
        Authorization: `Bearer ${token}`,
      },
    }
  },
  function (error) {
    updateToken()

    // Faz alguma coisa com o erro da requisição
    return Promise.reject(error)
  }
)
export const idOfUri = (uri: string) => uri.split(':')[2]

export const getArtistFromUri = (uri: string) => {
  return spotifyClient.get(`/artists/${idOfUri(uri)}`)
}
