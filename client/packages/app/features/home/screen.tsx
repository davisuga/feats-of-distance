import {
  Text,
  useSx,
  View,
  H1,
  P,
  Row,
  A,
  TextInput,
  Pressable,
  Image,
} from 'dripsy'
import { MotiPressable } from 'moti/interactions'
import React, { useState } from 'react'
import { TextLink } from 'solito/link'
import { MotiLink } from 'solito/moti'
import {
  Artist,
  useFeaturesQuery,
  useSearchArtistQuery,
} from '../../graphql/client'
import {
  fetchSpotifyToken,
  getArtistFromUri,
  getToken,
  idOfUri,
} from '../../rest/client'
import { debounce } from '../../utils/debounce'
import { ArtistList } from '../artist/ArtistList'
import { ArtistListItem } from '../artist/ArtistListItem'
import { useQuery } from 'react-query'
import { artistApi } from '../../rest/spotify-api'
import { uniq } from '../../utils/array'
const AnimatedButton: React.FC<{ onPress: () => void }> = ({
  children,
  onPress,
}) => {
  return (
    <MotiPressable
      onPress={onPress}
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
        {children}
      </Text>
    </MotiPressable>
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

  const { data: feats, refetch } = useFeaturesQuery(
    {
      from: selectedArtists.from?.uri || '',
      to: selectedArtists.to?.uri || '',
    },
    {
      enabled: false,
    }
  )

  const ids = uniq(
    feats?.features.flatMap((f) => [
      f.start.properties.uri,
      f.end.properties.uri,
    ]) || []
  ).map(idOfUri)

  const { data: info } = useQuery(
    ids,
    () => artistApi.getMultipleArtists(ids.join(',')),
    {
      enabled: !!feats?.features,
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
        <Text>From</Text>
        {selectedArtists.from && (
          <ArtistListItem onClick={console.log} data={selectedArtists.from} />
        )}

        <Text>To</Text>
        {selectedArtists.to && (
          <ArtistListItem onClick={console.log} data={selectedArtists.to} />
        )}
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
        <Pressable
          onPress={() => {
            setSelectedArtists({ from: undefined, to: undefined })
          }}
        >
          <Text>Clear selected artists</Text>
        </Pressable>
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
      {feats?.features.map((f) => (
        <View key={f.uri}>
          <Text>{f.start.properties.name}</Text>
          <Text>{f.properties.name}</Text>
          <Text>{f.end.properties.name}</Text>
        </View>
      ))}
      <Row>
        <AnimatedButton onPress={refetch}>
          <Text>Find feats!</Text>
        </AnimatedButton>
      </Row>
    </View>
  )
}
