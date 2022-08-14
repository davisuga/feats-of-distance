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
  FlatList,
} from 'dripsy'
import { MotiPressable } from 'moti/interactions'
import React, { useMemo, useState } from 'react'
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
import { removeDuplicatesBy, uniq } from '../../utils/array'
import { Track } from '../track/Track'
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
export const Spacer = <View sx={{ height: 16 }} />
export function HomeScreen() {
  const sx = useSx()

  const [searchTerm, setSearchTerm] = useState('')

  const [selectedArtists, setSelectedArtists] = useState<{
    from?: Artist
    to?: Artist
  }>({ from: undefined, to: undefined })

  const { data: searchData } = useSearchArtistQuery(
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

  // const featsArtists = useMemo(() => {

  //   const properties = feats?.features.flatMap(x => [x.start.properties, x.end.properties])
  //   return removeDuplicatesBy<typeof properties, "uri">("uri")(properties||[])}, [feats])

  const ids = uniq(
    feats?.features.flatMap((f) => [
      f.start.properties.uri,
      f.end.properties.uri,
    ]) || []
  ).map(idOfUri)

  const { data: artists } = useQuery(
    ids,
    () =>
      artistApi
        .getMultipleArtists(ids.join(','))
        .then((x) =>
          x.data.artists.map((a) => ({
            ...a,
            img: a.images?.[0]?.url || '',
            name: a.name,
          }))
        )
        .then(),
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

      {
        <ArtistList
          data={searchData}
          onClickItem={(item) =>
            setSelectedArtists({
              ...selectedArtists,
              [selectedArtists.from ? 'to' : 'from']: item,
            })
          }
        />
      }
      {Spacer}
      <View sx={{ display: 'flex' }}>
        {feats?.features && (
          <FlatList
            ListFooterComponent={
              <ArtistListItem
                onClick={console.log}
                data={selectedArtists.to!}
              />
            }
            ListHeaderComponent={
              <>
                <ArtistListItem
                  onClick={console.log}
                  data={selectedArtists.from!}
                />
                {Spacer}
              </>
            }
            ItemSeparatorComponent={() => Spacer}
            data={feats?.features}
            renderItem={({ item, index }) => {
              const lastArtist = feats?.features[index - 1]
              const startArtist = artists?.find(
                (x) => x.uri === item.start.properties.uri
              )
              const endArtist = artists?.find(
                (x) => x.uri === item.end.properties.uri
              )

              const artistToRender = [
                lastArtist?.start.properties.uri,
                lastArtist?.end.properties.uri,

                selectedArtists.to?.uri,
                selectedArtists.from?.uri,
              ].includes(startArtist?.uri)
                ? endArtist
                : startArtist

              return (
                <View>
                  <Track
                    id={item.properties.uri.replace('spotify:track:', '')}
                  />
                  <View sx={{ height: 16 }} />
                  {artistToRender && index !== feats?.features.length - 1 ? (
                    <ArtistListItem
                      data={artistToRender}
                      onClick={console.log}
                    />
                  ) : null}
                </View>
              )
            }}
          />
        )}
      </View>
      <Row>
        <AnimatedButton onPress={refetch}>
          <Text>Find feats!</Text>
        </AnimatedButton>
      </Row>
    </View>
  )
}
