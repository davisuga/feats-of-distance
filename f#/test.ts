import data from "./test-1646436321675.json" assert { type: "json" };

// import queryArtistDiscographyAlbuns from "./queryArtistDiscographyAlbums.ts";
// import searchDesktop from "./searchDesktop.ts";
// const result = await fetch(
//   "https://api-partner.spotify.com/pathfinder/v1/query?operationName=searchDesktop&variables=%7B%22searchTerm%22%3A%22justin+bieber%22%2C%22offset%22%3A0%2C%22limit%22%3A10%2C%22numberOfTopResults%22%3A5%7D&extensions=%7B%22persistedQuery%22%3A%7B%22version%22%3A1%2C%22sha256Hash%22%3A%229542c8275ed5dd875f7ef4b2446da1cd796861f649fa4c244103364083830edd%22%7D%7D",
//   {
//     headers: {
//       accept: "application/json",
//       "accept-language": "en",
//       "app-platform": "WebPlayer",
//       authorization:
//         "Bearer BQCN4eFWduwXTDMS1EUXRsEpN5ppjuHQR8JZY8RX3H3hwB8g65co6sTyD8bvcVTlMGoPezo_NdNk2DEHpkY",
//       "content-type": "application/json;charset=UTF-8",
//       "sec-ch-ua":
//         '" Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"',
//       "sec-ch-ua-mobile": "?0",
//       "sec-ch-ua-platform": '"Linux"',
//       "sec-fetch-dest": "empty",
//       "sec-fetch-mode": "cors",
//       "sec-fetch-site": "same-site",
//       "spotify-app-version": "1.1.81.88.g5e9024a5",
//     },
//     referrer: "https://open.spotify.com/",
//     referrerPolicy: "strict-origin-when-cross-origin",
//     body: null,
//     method: "GET",
//     mode: "cors",
//     credentials: "include",
//   }
// );

const artistName = searchDesktop.data.searchV2.artists.items[0].data.uri;
const albumIds =
  queryArtistDiscographyAlbuns.data.artist.discography.albums.items.flatMap(
    (a) => a.releases.items.map((i) => i.id)
  );

// console.log(await result.json());
