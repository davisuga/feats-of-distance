import { useQuery, UseQueryOptions } from 'react-query'
export type Maybe<T> = T | null
export type InputMaybe<T> = Maybe<T>
export type Exact<T extends { [key: string]: unknown }> = {
  [K in keyof T]: T[K]
}
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & {
  [SubKey in K]?: Maybe<T[SubKey]>
}
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & {
  [SubKey in K]: Maybe<T[SubKey]>
}

function fetcher<TData, TVariables>(query: string, variables?: TVariables) {
  return async (): Promise<TData> => {
    const res = await fetch('http://feats-of-distance.herokuapp.com/graphql', {
      method: 'POST',
      ...{ headers: { 'Content-Type': 'application/json' } },
      body: JSON.stringify({ query, variables }),
    })

    const json = await res.json()

    if (json.errors) {
      const { message } = json.errors[0]

      throw new Error(message)
    }

    return json.data
  }
}
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string
  String: string
  Boolean: boolean
  Int: number
  Float: number
}

export type Artist = {
  __typename?: 'artist'
  img?: Maybe<Scalars['String']>
  name: Scalars['String']
  uri: Scalars['String']
}

export type Query = {
  __typename?: 'query'
  artists: Array<Artist>
}

export type QueryArtistsArgs = {
  search_term?: InputMaybe<Scalars['String']>
}

export type SearchArtistQueryVariables = Exact<{
  searchTerm: Scalars['String']
}>

export type SearchArtistQuery = {
  __typename?: 'query'
  artists: Array<{
    __typename?: 'artist'
    name: string
    uri: string
    img?: string | null
  }>
}

export const SearchArtistDocument = `
    query searchArtist($searchTerm: String!) {
  artists(search_term: $searchTerm) {
    name
    uri
    img
  }
}
    `
export const useSearchArtistQuery = <
  TData = SearchArtistQuery,
  TError = unknown
>(
  variables: SearchArtistQueryVariables,
  options?: UseQueryOptions<SearchArtistQuery, TError, TData>
) =>
  useQuery<SearchArtistQuery, TError, TData>(
    ['searchArtist', variables],
    fetcher<SearchArtistQuery, SearchArtistQueryVariables>(
      SearchArtistDocument,
      variables
    ),
    options
  )
