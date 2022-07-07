import { FlatList } from 'dripsy'
import React from 'react'
import { Artist, SearchArtistQuery } from '../../../graphql/client'
import { ArtistListItem } from '../ArtistListItem'
type ArtistListProps = {
  data?: SearchArtistQuery
  onClickItem: (val: Artist) => void
}

export const ArtistList = ({ data, onClickItem }: ArtistListProps) => {
  const renderItem = ({ item }: { item: Artist }) => {
    return <ArtistListItem key={item.uri} data={item} onClick={onClickItem} />
  }
  return <FlatList data={data?.artists || []} renderItem={renderItem} />
}
