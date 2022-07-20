import { Image, Row, Text, View } from 'dripsy'
import React from 'react'
import { Pressable } from 'react-native'
import { Artist, SearchArtistQuery } from '../../../graphql/client'
import { ItemOf } from '../../../utils/type'

type ArtistListItemProps<T = Artist> = {
  data: T
  onClick: (val: T) => void
}
export const ArtistListItem = (props: ArtistListItemProps) => {
  return (
    <Pressable onPress={() => props.onClick(props.data)}>
      <Row
        sx={{
          // width: '70%',
          backgroundColor: 'black',
          borderRadius: 5,

          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        {props.data.img && (
          <Image
            sx={{
              width: 70,
              height: 70,
              borderRadius: 5,
            }}
            accessibilityLabel="artist-pic"
            source={{ uri: props.data.img }}
          />
        )}
        <Text
          sx={{
            marginLeft: 2,
            marginRight: 2,

            color: 'white',
            fontWeight: 'bold',
          }}
        >
          {props.data.name}
        </Text>
      </Row>
    </Pressable>
  )
}
