import { useQuery, UseQueryOptions } from 'react-query';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };

function fetcher<TData, TVariables>(query: string, variables?: TVariables) {
  return async (): Promise<TData> => {
    const res = await fetch("http://localhost:8081/graphql", {
    method: "POST",
    ...({"headers":{"Content-Type":"application/json"}}),
      body: JSON.stringify({ query, variables }),
    });

    const json = await res.json();

    if (json.errors) {
      const { message } = json.errors[0];

      throw new Error(message);
    }

    return json.data;
  }
}
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
};

export type Artist = {
  __typename?: 'Artist';
  description?: Maybe<Scalars['String']>;
  img?: Maybe<Scalars['String']>;
  name: Scalars['String'];
  uri: Scalars['String'];
};

export type Feature = {
  __typename?: 'Feature';
  end: Node;
  properties: Properties;
  start: Node;
  uri: Scalars['String'];
};

export type Node = {
  __typename?: 'Node';
  id: Scalars['String'];
  labels: Array<Scalars['String']>;
  properties: Properties;
};

export type Properties = {
  __typename?: 'Properties';
  name: Scalars['String'];
  uri: Scalars['String'];
};

export type Query = {
  __typename?: 'query';
  artist: Node;
  artists: Array<Artist>;
  features: Array<Feature>;
};


export type QueryArtistArgs = {
  uri?: InputMaybe<Scalars['String']>;
};


export type QueryArtistsArgs = {
  search_term?: InputMaybe<Scalars['String']>;
};


export type QueryFeaturesArgs = {
  from?: InputMaybe<Scalars['String']>;
  limit?: InputMaybe<Scalars['Int']>;
  to?: InputMaybe<Scalars['String']>;
};

export type SearchArtistQueryVariables = Exact<{
  searchTerm: Scalars['String'];
}>;


export type SearchArtistQuery = { __typename?: 'query', artists: Array<{ __typename?: 'Artist', name: string, uri: string, img?: string | null }> };

export type FeaturesQueryVariables = Exact<{
  from: Scalars['String'];
  to: Scalars['String'];
}>;


export type FeaturesQuery = { __typename?: 'query', features: Array<{ __typename?: 'Feature', uri: string, properties: { __typename?: 'Properties', name: string, uri: string }, end: { __typename?: 'Node', properties: { __typename?: 'Properties', name: string, uri: string } }, start: { __typename?: 'Node', properties: { __typename?: 'Properties', name: string, uri: string } } }> };


export const SearchArtistDocument = `
    query searchArtist($searchTerm: String!) {
  artists(search_term: $searchTerm) {
    name
    uri
    img
  }
}
    `;
export const useSearchArtistQuery = <
      TData = SearchArtistQuery,
      TError = unknown
    >(
      variables: SearchArtistQueryVariables,
      options?: UseQueryOptions<SearchArtistQuery, TError, TData>
    ) =>
    useQuery<SearchArtistQuery, TError, TData>(
      ['searchArtist', variables],
      fetcher<SearchArtistQuery, SearchArtistQueryVariables>(SearchArtistDocument, variables),
      options
    );
export const FeaturesDocument = `
    query features($from: String!, $to: String!) {
  features(to: $to, from: $from) {
    uri
    properties {
      name
      uri
    }
    end {
      properties {
        name
        uri
      }
    }
    start {
      properties {
        name
        uri
      }
    }
  }
}
    `;
export const useFeaturesQuery = <
      TData = FeaturesQuery,
      TError = unknown
    >(
      variables: FeaturesQueryVariables,
      options?: UseQueryOptions<FeaturesQuery, TError, TData>
    ) =>
    useQuery<FeaturesQuery, TError, TData>(
      ['features', variables],
      fetcher<FeaturesQuery, FeaturesQueryVariables>(FeaturesDocument, variables),
      options
    );