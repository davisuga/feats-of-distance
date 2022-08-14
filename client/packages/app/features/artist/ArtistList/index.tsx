import { FlatList, View } from 'dripsy'
import React from 'react'
import { ListRenderItem } from 'react-native'
import { Artist, SearchArtistQuery } from '../../../graphql/client'
import { Spacer } from '../../home/screen'
import { ArtistListItem } from '../ArtistListItem'
type ArtistListProps = {
  data?: SearchArtistQuery
  onClickItem: (val: Artist) => void
}

export const ArtistList = ({ data, onClickItem }: ArtistListProps) => {
  const renderItem = ({ item }: Parameters<ListRenderItem<Artist>>[0]) => {
    return (
      <View sx={{ margin: 10 }}>
        <ArtistListItem
          key={item.uri}
          data={item}
          onClick={onClickItem}
          imgStyle={{}}
          style={{}}
        />
      </View>
    )
  }
  //@ts-ignore
  return (
    <FlatList
      data={data?.artists || []}
      renderItem={renderItem}
      numColumns={4}
    />
  )
}
