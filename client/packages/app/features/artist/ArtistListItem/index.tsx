import { Image, Row, Styles, SxProp, Text, View } from 'dripsy'
import React from 'react'
import { Platform, Pressable } from 'react-native'
import { Artist, SearchArtistQuery } from '../../../graphql/client'
import { ItemOf } from '../../../utils/type'

type ArtistListItemProps<T = Artist> = {
  data: T
  onClick: (val: T) => void
  imgStyle: SxProp
  style: SxProp
}
export const ArtistListItem = (props: ArtistListItemProps) => {
  globalThis['env'] = process.env
  return (
    <Pressable onPress={() => props.onClick(props.data)}>
      <Row
        sx={{
          borderRadius: 5,
          background: 'black',
        }}
      >
        {props.data.img && (
          <>
            <Image
              sx={{
                width: 150,
                height: 150,
                borderRadius: 5,
                ...props.imgStyle,
              }}
              accessibilityLabel="artist-pic"
              source={{ uri: props.data.img }}
            />
            <View
              sx={{
                width: props.imgStyle.width || 150,
                height: 150,
                borderRadius: 5,

                position: 'absolute',
                ...props.style,
              }}
              style={{
                //@ts-ignore Background property exists
                background:
                  Platform.OS === 'web'
                    ? 'linear-gradient(180deg, #fff0, #0004)'
                    : 'black',
              }}
            ></View>
          </>
        )}
        <Text
          sx={{
            marginLeft: 2,
            marginRight: 2,
            position: 'absolute',
            color: 'white',
            fontWeight: 'bold',
            maxWidth: 150,
            wordWrap: 'break-word',
            fontSize: 24,
            bottom: 12,
          }}
        >
          {props.data.name}
        </Text>
      </Row>
    </Pressable>
  )
}
