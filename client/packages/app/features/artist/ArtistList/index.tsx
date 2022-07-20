import { FlatList } from 'dripsy'
import React from 'react'
import { ListRenderItem } from 'react-native'
import { Artist, SearchArtistQuery } from '../../../graphql/client'
import { ArtistListItem } from '../ArtistListItem'
type ArtistListProps = {
  data?: SearchArtistQuery
  onClickItem: (val: Artist) => void
}

export const ArtistList = ({ data, onClickItem }: ArtistListProps) => {
  const renderItem = ({ item }: Parameters<ListRenderItem<Artist>>[0]) => {
    return <ArtistListItem key={item.uri} data={item} onClick={onClickItem} />
  }
  //@ts-ignore
  return <FlatList data={data?.artists || []} renderItem={renderItem} />
}
