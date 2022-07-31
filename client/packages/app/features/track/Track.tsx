import { Platform } from 'react-native'

export const Track = ({ id }: { id: string }) => {
  if (Platform.OS === 'web') {
    return (
      <iframe
        style={{ borderRadius: 12 }}
        src={`https://open.spotify.com/embed/track/${id}?utm_source=generator`}
        width="100%"
        height="80"
        frameBorder="0"
        allowfullscreen=""
        allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture"
      ></iframe>
    )
  }
  return null
}
