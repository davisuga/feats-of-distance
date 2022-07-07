import { Text, useSx, View, H1, P, Row, A, TextInput, Pressable } from 'dripsy'
import React, { useState } from 'react'
import { TextLink } from 'solito/link'
import { MotiLink } from 'solito/moti'
import { Artist, useSearchArtistQuery } from '../../graphql/client'
import { debounce } from '../../utils/debounce'
import { ArtistList } from '../artist/ArtistList'

function FindFeatsButton() {
  return (
    <MotiLink
      href="/user/fernando"
      animate={({ hovered, pressed }) => {
        'worklet'

        return {
          scale: pressed ? 0.95 : hovered ? 1.1 : 1,
          rotateZ: pressed ? '0deg' : hovered ? '-3deg' : '0deg',
        }
      }}
      transition={{
        type: 'timing',
        duration: 150,
      }}
    >
      <Text
        selectable={false}
        sx={{
          fontSize: 16,
          color: 'black',
          fontWeight: 'bold',
        }}
      >
        <Text>Find feats of distance!</Text>
      </Text>
    </MotiLink>
  )
}

export function HomeScreen() {
  const sx = useSx()

  const [searchTerm, setSearchTerm] = useState('')

  const [selectedArtists, setSelectedArtists] = useState<{
    from?: Artist
    to?: Artist
  }>({ from: undefined, to: undefined })

  const { data } = useSearchArtistQuery(
    {
      searchTerm,
    },
    {
      enabled: !!searchTerm,
    }
  )

  return (
    <View
      sx={{
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        p: 16,
        backgroundColor: 'white',
      }}
    >
      <H1 sx={{ fontWeight: '800' }}>Welcome to Feats of Distance.</H1>
      <View sx={{ maxWidth: 600 }}>
        <P sx={{ textAlign: 'center' }}>Search for an artist</P>

        <TextInput
          sx={{
            borderColor: 'black',
            borderWidth: 1,

            borderRadius: 100,
            width: 200,
            padding: 2,
          }}
          onChangeText={debounce(setSearchTerm, 250)}
        />
      </View>
      <View sx={{ height: 32, backgroundColor: 'black' }} />

      <ArtistList
        data={data}
        onClickItem={(item) =>
          setSelectedArtists({
            ...selectedArtists,
            [selectedArtists.from ? 'to' : 'from']: item,
          })
        }
      />
      <Row>
        <FindFeatsButton></FindFeatsButton>
      </Row>
    </View>
  )
}
// Accept: */*
// Accept-Encoding: gzip, deflate
// Accept-Language: en-US,en;q=0.9,pt-BR;q=0.8,pt;q=0.7,zh-CN;q=0.6,zh;q=0.5
// Access-Control-Request-Headers: content-type
// Access-Control-Request-Method: POST
// Connection: keep-alive
// Host: 192.168.1.190:8080
// Origin: http://localhost:3000
// Referer: http://localhost:3000/
// Sec-Fetch-Mode: cors
// User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.0.0 Safari/537.36
