open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.Hosting
open Giraffe
open Microsoft.AspNetCore.Http
open Neo4j.Driver
open System.Threading.Tasks
open HttpFs.Client
open Hopac
open System.Text.Json
open FSharp.Data
open System.Web
type Author = { name : string; img: string; id: string }
open System.Reflection
open System.IO
open System.Text.RegularExpressions


let toQueryString x =
    let formatElement (pi : PropertyInfo) =
        sprintf "%s=%O" pi.Name <| pi.GetValue x
    x.GetType().GetProperties()
    |> Array.map formatElement
    |> String.concat "&"
    



[<Literal>]
let apiResult = "./drake.json"
[<Literal>]
let searchDesktopResult = "./searchDesktop.json"
type SearchDesktop = JsonProvider<searchDesktopResult>
[<Literal>]
let queryAlbumTracksResult = "./queryAlbumTracks.json"
type QueryAlbumTracks = JsonProvider<queryAlbumTracksResult>
[<Literal>]
let queryArtistDiscographyAlbumsResult = "./queryArtistDiscographyAlbums.json"
type QueryArtistDiscographyAlbums = JsonProvider<queryArtistDiscographyAlbumsResult>

type ApiResult = JsonProvider<apiResult>
type Song = {
    sid: string;
    author: Author;
    name: string;
    image: string
}
open Microsoft.FSharp.Collections
open System
open System.IO
type getAuthorByName = string -> Author

type SearchOptions = {
    searchTerm: string;
    limit: int ;
    offset: int ;
}

let defaultSearchOptions = {
    searchTerm =  ""
    limit =  1
    offset =  1
}

type TokenResponse = {
    token: string;
    captures: string;
    source: string
}

let defaultExtensionsQ = """{"persistedQuery":{"version":1,"sha256Hash":"9542c8275ed5dd875f7ef4b2446da1cd796861f649fa4c244103364083830edd"}}"""
let getTokenFromHtml (html: string) =
    let groups = Seq.map (fun (x: Group) -> x.Value) (Regex.Match(            html,
            "accessToken\":\"(.+?)\"").Groups.Values) |> Seq.fold (+) ""
    {
        token = groups.Replace("accessToken\":\"", "").Replace("\",\"", "")
        captures = groups
        source = html
    }

let newToken _ =
    Request.createUrl Get ("https://open.spotify.com")
    |> Request.setHeader (Custom     ("user-agent","Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36"))
    |> Request.responseAsString
    |> run
    |> getTokenFromHtml

let headers = [
    ["authority";"api-partner.spotify.com"];
    ["sec-ch-ua";""" "Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98" """];
    ["accept-language";"en"];
    ["sec-ch-ua-mobile";"?0"];
    // ["content-type";"application/json;charset=UTF-8"];
    ["accept";"application/json"];
    ["user-agent";"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36"];
    ["spotify-app-version";"1.1.81.88.g5e9024a5"];
    ["app-platform";"WebPlayer"];
    // ["sec-ch-ua-platform";""" "Linux" """];
    ["origin";"https://open.spotify.com"];
    ["sec-fetch-site";"same-site"];
    ["sec-fetch-mode";"cors"];
    ["sec-fetch-dest";"empty"];
    ["referer";"https://open.spotify.com/"];
]

let makeHeadersFromList  =
    List.map(fun [k; v] -> Custom(k, v)) 

let rec composeHeaders  headers req =
    match headers with
    | firstHeader :: rest -> composeHeaders  rest (Request.setHeader firstHeader req)
    | [] -> req

let headerList =  makeHeadersFromList headers

let addTokenPrefix token =
    let tokenPrefix = "Bearer "
    in tokenPrefix + token

let searchDesktop name  =
    Request.createUrl Get ("https://api-partner.spotify.com/pathfinder/v1/query?operationName=searchDesktop&variables=%7B%22searchTerm%22%3A%22"+name+"%22%2C%22offset%22%3A0%2C%22limit%22%3A10%2C%22numberOfTopResults%22%3A5%7D&extensions=%7B%22persistedQuery%22%3A%7B%22version%22%3A1%2C%22sha256Hash%22%3A%229542c8275ed5dd875f7ef4b2446da1cd796861f649fa4c244103364083830edd%22%7D%7D")

    // |> Request.queryStringItem "operatioName" "searchDesktop"
    // |> Request.queryStringItem "variables"  (JsonSerializer.Serialize {defaultSearchOptions with searchTerm = name} )
    // |> Request.queryStringItem "extensions" defaultExtensionsQ
    |> composeHeaders headerList
    |> Request.responseAsString

let queryArtistDiscographyAlbums artistID =
    Request.createUrl Get ("https://api-partner.spotify.com/pathfinder/v1/query?operationName=queryArtistDiscographyAlbums&variables=%7B%22uri%22%3A%22spotify%3Aartist%3A"+artistID+"%22,%22offset%22%3A0,%22limit%22%3A50%7D&extensions=%7B%22persistedQuery%22%3A%7B%22version%22%3A1,%22sha256Hash%22%3A%22e38c23e4e8aa873903ab47c2c84ab9f1175e645cf03a34eafdeea07454e5c3da%22%7D%7D")
    |> composeHeaders headerList
    |> Request.responseAsString

let reqQueryAlbumTracks albumID additionalHeaders = 
    Request.createUrl Get ("https://api-partner.spotify.com/pathfinder/v1/query?operationName=queryAlbumTracks&variables=%7B%22uri%22%3A%22spotify%3Aalbum%3A"+albumID+"%22,%22offset%22%3A0,%22limit%22%3A300%7D&extensions=%7B%22persistedQuery%22%3A%7B%22version%22%3A1,%22sha256Hash%22%3A%223ea563e1d68f486d8df30f69de9dcedae74c77e684b889ba7408c589d30f7f2e%22%7D%7D")
    |> composeHeaders (List.append headerList  additionalHeaders)


let queryAlbumTracks albumID = 
    reqQueryAlbumTracks albumID []
    |> Request.responseAsString

let getIdFromURI (s: string)  = s.Split(":")[2]

let isOk res =
    match res with
    | Ok _ -> true
    | Error _ -> false

let unwrapResult res =
    match res with
    | Ok x -> Some x |> Option.get
    | Error _ -> None |> Option.get

let tap effect x = 
        effect x |> ignore
        x
        
let artistByName name = 
    try 
    searchDesktop name
    |> run
        |> SearchDesktop.Parse
        |> tap (fun data -> File.WriteAllText("artist_"+name, data.ToString()))
        |> (fun x -> Ok x.Data.SearchV2.Artists.Items[0].Data) 
    with ex ->
         Error(ex.Message)

type getAllFeatsByAuthor = Author -> Song[]

type saveFeat = Author[] -> Song -> Task<string>

let ssecret = "a2d57c4b98f24728a4fc0ac61dd1ffb2"


let dbConn _ = 
    let driver = GraphDatabase.Driver("neo4j://localhost:7687", AuthTokens.Basic("neo4j", "BpWilDx5Ox3wG8NS9OI9FB-F9zYCGmSjJ3aMyOZLTKw"))
    driver.AsyncSession(fun o -> o.WithDatabase("neo4j") |> ignore)



let flip f x y = f y x

let logInfo (info: string) =
    Console.WriteLine(info)
    File.AppendAllText("logs.log", $"{DateTime.Now}: {info}\n")

let getJobResponse req = 
    job {
                    
                    use! response = getResponse req
                    return response
    }

let rec tryQueryAlbumTracks requestHeaders id =
        try
            let res = getJobResponse (reqQueryAlbumTracks id requestHeaders ) |> run
            match res.statusCode with 
                    | 200 ->  
                        logInfo $"200 with id {id}"
                        res |> Response.readBodyAsString |> run |> QueryAlbumTracks.Parse |> Ok 
                    | 401 -> 
                        logInfo $"401 with id {id}"
                        tryQueryAlbumTracks  [Custom ("authorization", addTokenPrefix(newToken().token))] id
                    | 429 | _ -> 
                        logInfo $"429 with id {id}"
                        System.Threading.Thread.Sleep 100
                        tryQueryAlbumTracks  [] id
        with ex ->
          Error $"Error {ex.ToString()} with {id}"

let getTracks (a:QueryAlbumTracks.Root) = a.Data.Album.Tracks.Items

let tracePipe message = tap (fun a -> message + " " + a.ToString())

let searchTracksForAlbum (album: QueryArtistDiscographyAlbums.Root) =   
    album.Data.Artist.Discography.Albums.Items
    |> Array.Parallel.collect(fun a -> a.Releases.Items )
    // |> Array.Parallel.map( fun y ->  File.WriteAllText("albums_2"+y.Uri, y.ToString()) |> ignore |> (fun _ -> y))
    |> Array.Parallel.map(fun a -> a.Id )
    |> tracePipe "Got ids"
    |> Array.Parallel.map(tryQueryAlbumTracks [])
    |> tracePipe "tryQueryAlbumTracks"
    |> Array.Parallel.collect (fun a -> match a with
                                        | Ok x -> getTracks x
                                        | Error e -> 
                                        
                                        File.AppendAllText("errors", e.ToString())
                                        [||]
                                )
    |> Array.Parallel.map( fun y ->  File.WriteAllText("tracks/"+y.Track.Uri, y.ToString()) |> ignore |> (fun _ -> y.ToString()))

let readDiscographies dir = 
    Directory.GetFiles(dir, "*.json")
    |> Array.Parallel.map (QueryArtistDiscographyAlbums.Load)
    |> Array.Parallel.map searchTracksForAlbum

let tops = [|
    "Drake";
    "Ed Sheeran";
    "Bad Bunny";
    "The Weeknd";
    "Ariana Grande";
    "Justin Bieber";
    "Post Malone";
    "Eminem";
    "Taylor Swift";
    "BTS";
    "J Balvin";
    "Kanye West";
    "Billie Eilish";
    "Juice WRLD";
    "Coldplay";
    "Ozuna";
    "XXXTENTACION";
    "Khalid";
    "Imagine Dragons";
    "Dua Lipa";
    "Travis Scott";
    "Rihanna";
    "Maroon 5";
    "Shawn Mendes";
    "David Guetta";
    "Calvin Harris";
    "Bruno Mars";
    "Daddy Yankee";
    "Sam Smith";
    "Queen";
    "Kendrick Lamar";
    "The Chainsmokers";
    "Chris Brown";
    "One Direction";
    "Beyoncé";
    "Future";
    "Sia";
    "Nicki Minaj";
    "Lady Gaga";
    "J. Cole";
    "Halsey";
    "Selena Gomez";
    "Anuel AA";
    "The Beatles";
    "Adele";
    "Maluma";
    "Twenty One Pilots";
    "Marshmello";
    "Lil Uzi Vert";
    "Linkin Park";
    "Kygo";
    "Katy Perry";
    "Avicii";
    "Farruko";
    "Lana Del Rey";
    "Camila Cabello";
    "Jason Derulo";
    "Rauw Alejandro";
    "Demi Lovato";
    "Red Hot Chili Peppers";
    "Arctic Monkeys";
    "Shakira";
    "Nicky Jam";
    "OneRepublic";
    "Martin Garrix";
    "Miley Cyrus";
    "Doja Cat";
    "KAROL G";
    "Michael Jackson";
    "Harry Styles";
    "G-Eazy";
    "Pitbull";
    "Major Lazer";
    "Panic! At The Disco";
    "Cardi B";
    "Charlie Puth";
    "Ellie Goulding";
    "Sebastian Yatra";
    "DaBaby";
    "Sech";
    "Lil Wayne";
    "Young Thug";
    "Wiz Khalifa";
    "Lil Baby";
    "21 Savage";
    "Pop Smoke";
    "Fall Out Boy";
    "Mac Miller";
    "Diplo";
    "Logic";
    "Migos";
    "Myke Towers";
    "Metallica";
    "John Mayer";
    "Tyga";
    "Alan Walker";
    "P!nk";
    "Lil Peep";
    "DJ Snake";
    "ZAYN";
    "Macklemore";
    "Lauv";
    "James Arthur";
    "AC/DC";
    "Little Mix";
    "Lil Nas X";
    "Trippie Redd";
    "Zedd";
    "Bob Marley & The Wailers";
    "A$AP Rocky";
    "A Boogie Wit da Hoodie";
    "5 Seconds of Summer";
    "NF";
    "Robin Schulz";
    "Kodak Black";
    "Gunna";
    "Olivia Rodrigo";
    "Elton John";
    "Tiësto";
    "Bebe Rexha";
    "Frank Ocean";
    "Green Day";
    "Justin Timberlake";
    "Metro Boomin";
    "Romeo Santos";
    "Clean Bandit";
    "YoungBoy Never Broke Again";
    "DJ Khaled";
    "Zara Larsson";
    "Luis Miguel";
    "Anne-Marie";
    "Lewis Capaldi";
    "Michael Bublé";
    "Tyler, The Creator";
    "Enrique Iglesias";
    "Black Eyed Peas";
    "Pink Floyd";
    "SZA";
    "Flo Rida";
    "Ty Dolla $ign";
    "BLACKPINK";
    "The Rolling Stones";
    "Jonas Blue";
    "Nirvana";
    "JAY-Z";
    "Luis Fonsi";
    "$uicideboy$";
    "Machine Gun Kelly";
    "blackbear";
    "Britney Spears";
    "Russ";
    "Fleetwood Mac";
    "Guns N' Roses";
    "Reik";
    "Marília Mendonça";
    "Bastille";
    "Banda MS de Sergio Lizárraga";
    "Anitta";
    "Kid Cudi";
    "Childish Gambino";
    "Camilo";
    "2Pac";
    "Skrillex";
    "Lorde";
    "Mariah Carey";
    "Alessia Cara";
    "Big Sean";
    "50 Cent";
    "Gorillaz";
    "Usher";
    "Hozier";
    "David Bowie";
    "Polo G";
    "The Neighbourhood";
    "Becky G";
    "The Kid LAROI";
    "Ava Max";
    "Jhay Cortez";
    "The Killers";
    "Meek Mill";
    "Foo Fighters";
    "John Legend";
    "Tory Lanez";
    "U2";
    "Meghan Trainor";
    "Luke Combs";
    "Led Zeppelin";
    "Daft Punk";
    "blink-182";
    "French Montana";
    "Rita Ora";
    "The 1975";
    "Rae Sremmurd";
    "Troye Sivan";
    "Radiohead";
    "Gucci Mane";
    "Elvis Presley";
    "System Of A Down";
    "Mumford & Sons";
    "Manuel Turizo";
    "Megan Thee Stallion";
    "6ix9ine";
    "Jack Johnson";
    "Jorge & Mateus";
    "Snoop Dogg";
    "Joji";
    "The Notorious B.I.G.";
    "Muse";
    "Roddy Ricch";
    "Bazzi";
    "Playboi Carti";
    "Don Omar";
    "Swae Lee";
    "Christina Aguilera";
    "Paramore";
    "Hailee Steinfeld";
    "Bon Jovi";
    "Slipknot";
    "Labrinth";
    "Julia Michaels";
    "Ne-Yo";
    "Jess Glynne";
    "Oasis";
    "Melanie Martinez";
    "Christian Nodal";
    "Dalex";
    "The Lumineers";
    "Disclosure";
    "Tame Impala";
    "Alicia Keys";
    "Fifth Harmony";
    "Florida Georgia Line";
    "Kings of Leon";
    "Justin Quiles";
    "Cheat Codes";
    "Chance the Rapper";
    "Gusttavo Lima";
    "Felix Jaehn";
    "Sean Paul";
    "Luke Bryan";
    "Frank Sinatra";
    "Tove Lo";
    "6LACK";
    "The Script";
    "ABBA";
    "Piso 21";
    "Natti Natasha";
    "Five Finger Death Punch";
    "Jason Mraz";
    "Alesso";
    "Alok";
    "Glee Cast";
    "Zé Neto & Cristiano";
    "Florence + The Machine";
    "Creedence Clearwater Revival";
    "Paulo Londra";
    "TWICE";
    "Madonna";
    "Galantis";
    "Bruce Springsteen";
    "Whitney Houston";
    "My Chemical Romance";
    "Kane Brown";
    "Rammstein";
    "Zion & Lennox";
    "Kehlani";
    "Niall Horan";
    "Morat";
    "Lenny Tavárez";
    "Morgan Wallen";
    "Arcangel";
    "Lil Pump";
    "Macklemore & Ryan Lewis";
    "Bryson Tiller";
    "Kelly Clarkson";
    "Nickelback";
    "Capital Bra";
    "Jonas Brothers";
    "Avril Lavigne";
    "Bring Me The Horizon";
    "Stevie Wonder";
    "James Bay";
    "NAV";
    "Disturbed";
    "Wisin";
    "Thomas Rhett";
    "Aerosmith";
    "Alejandro Fernández";
    "Jennifer Lopez";
    "YG";
    "Vance Joy";
    "Amy Winehouse";
    "Dr. Dre";
    "Lil Tecca";
    "Jack Harlow";
    "Lil Tjay";
    "Tones And I";
    "Lil Skies";
    "Backstreet Boys";
    "Miguel";
    "Henrique & Juliano";
    "Maná";
    "Kesha";
    "Kevin Gates";
    "Ryan Lewis";
    "YNW Melly";
    "Flume";
    "Wisin & Yandel";
    "Duki";
    "Phil Collins";
    "Yandel";
    "Nio Garcia";
    "Billy Joel";
    "Akon";
    "Eagles";
    "Three Days Grace";
    "Jason Aldean";
    "Prince Royce";
    "Hans Zimmer";
    "Avenged Sevenfold";
    "Matheus & Kauan";
    "Jeremih";
    "Glass Animals";
    "George Ezra";
    "The Offspring";
    "Fetty Wap";
    "Aventura";
    "Lin-Manuel Miranda";
    "The Strokes";
    "Lil Mosey";
    "Wesley Safadão";
    "Jessie J";
    "Céline Dion";
    "Jul";
    "2 Chainz";
    "Steve Aoki";
    "benny blanco";
    "Passenger";
    "Calibre 50";
    "Alejandro Sanz";
    "Dan + Shay";
    "Ricky Martin";
    "Trey Songz";
    "Pentatonix";
    "Mark Ronson";
    "H.E.R.";
    "CNCO";
    "Train";
    "24kGoldn";
    "Lizzo";
    "Why Don't We";
    "Don Toliver";
    "Anderson .Paak";
    "Seeb";
    "Ninho";
    "Lukas Graham";
    "Pablo Alborán";
    "Pearl Jam";
    "Bob Dylan";
    "Foster The People";
    "Ricardo Arjona";
    "Johnny Cash";
    "Marc Anthony";
    "Lost Frequencies";
    "R3HAB";
    "James Blunt";
    "Daniel Caesar";
    "Quavo";
    "Cartel De Santa";
    "Dire Straits";
    "Bryan Adams";
    "Sam Hunt";
    "PARTYNEXTDOOR";
    "Bee Gees";
    "Ski Mask The Slump God";
    "ScHoolboy Q";
    "Maiara & Maraisa";
    "Dean Lewis";
    "Sigala";
    "Nelly";
    "Rex Orange County";
    "Liam Payne";
    "Charli XCX";
    "Alec Benjamin";
    "Arijit Singh";
    "alt-J";
    "Rudimental";
    "Marvin Gaye";
    "Jhené Aiko";
    "Lil Yachty";
    "Offset";
    "Måneskin";
    "Blake Shelton";
    "Lil Durk";
    "Danny Ocean";
    "BROCKHAMPTON";
    "Armin van Buuren";
    "Zac Brown Band";
    "The Vamps";
    "Carlos Vives";
    "Mike Posner";
    "Bon Iver";
    "The Police";
    "Iron Maiden";
    "Skillet";
    "Summer Walker";
    "LANY";
    "Cage The Elephant";
    "JP Cooper";
    "The Black Keys";
    "Tim McGraw";
    "ILLENIUM";
    "Birdy";
    "Conan Gray";
    "Maren Morris";
    "Rise Against";
    "Jeremy Zucker";
    "Madison Beer";
    "Mau y Ricky";
    "A$AP Ferg";
    "Juanes";
    "Weezer";
    "ROSALÍA";
    "The Doors";
    "Carly Rae Jepsen";
    "Soda Stereo";
    "Papa Roach";
    "Bizarrap";
    "Lunay";
    "Bradley Cooper";
    "Calum Scott";
    "T.I.";
    "RAF Camora";
    "Joan Sebastian";
    "Journey";
    "Mabel";
    "Korn";
    "Chris Stapleton";
    "iann dior";
    "Eric Church";
    "Becky Hill";
    "The Cure";
    "Noah Cyrus";
    "Iggy Azalea";
    "Juan Gabriel";
    "SAINt JHN";
    "Boyce Avenue";
    "Kenny Chesney";
    "Os Barões Da Pisadinha";
    "Paul McCartney";
    "EXO";
    "Destiny's Child";
    "Norah Jones";
    "Jesse & Joy";
    "Vicente Fernández";
    "Depeche Mode";
    "Tate McRae";
    "John Williams";
    "Nick Jonas";
    "Aminé";
    "Bibi Blocksberg";
    "Imanbek";
    "Normani";
    "Kali Uchis";
    "PNL";
    "NLE Choppa";
    "Hillsong UNITED";
    "Breaking Benjamin";
    "Jon Bellion";
    "The xx";
    "Matoma";
    "MARINA";
    "Simon & Garfunkel";
    "X Ambassadors";
    "Sabrina Carpenter";
    "George Michael";
    "Rich The Kid";
    "The Beach Boys";
    "Ufo361";
    "Hillsong Worship";
    "La Arrolladora Banda El Limón De Rene Camacho";
    "Los Ángeles Azules";
    "Volbeat";
    "Christina Perri";
    "Bonez MC";
    "Grupo Firme";
    "R.E.M.";
    "MAGIC!";
    "Jimi Hendrix";
    "Years & Years";
    "Sam Feldt";
    "KYLE";
    "bbno$";
    "KHEA";
    "El Alfa";
    "Eric Clapton";
    "Rick Ross";
    "Kid Ink";
    "The Fray";
    "Stormzy";
    "MEDUZA";
    "C. Tangana";
    "Dimitri Vegas & Like Mike";
    "Van Morrison";
    "All Time Low";
    "The Game";
    "Earth, Wind & Fire";
    "Dermot Kennedy";
    "T-Pain";
    "Robbie Williams";
    "Milky Chance";
    "Grey";
    "Stray Kids";
    "Lynyrd Skynyrd";
    "DNCE";
    "AJR";
    "Shinedown";
    "Cali Y El Dandee";
    "Outkast";
    "B.o.B";
    "Samra";
    "Hollywood Undead";
    "Rag'n'Bone Man";
    "Jax Jones";
    "The Cranberries";
    "Of Monsters and Men";
    "Plan B";
    "The Smiths";
    "Van Halen";
    "A Day To Remember";
    "Keith Urban";
    "Black Sabbath";
    "Kodaline";
    "Daryl Hall & John Oates";
    "Rage Against The Machine";
    "Aya Nakamura";
    "Rod Stewart";
    "Andy Grammer";
    "PnB Rock";
    "Quinn XCII";
    "Juan Magán";
    "Brytiago";
    "Prince";
    "Sabaton";
    "Ludovico Einaudi";
    "The White Stripes";
    "Casper Magico";
    "De La Ghetto";
    "Sfera Ebbasta";
    "Topic";
    "Enya";
    "Nelly Furtado";
    "Carrie Underwood";
    "Sublime";
    "MGMT";
    "Aretha Franklin";
    "Evanescence";
    "Damso";
    "Shaggy";
    "GIMS";
    "Melendi";
    "WALK THE MOON";
    "Axwell /\\ Ingrosso";
    "RAYE";
    "George Strait";
    "TOTO";
    "Rels B";
    "Jay Wheeler";
    "Dave";
    "José José";
    "TINI";
    "Red Velvet";
    "Ozzy Osbourne";
    "Sum 41";
    "Don Diablo";
    "Scorpions";
    "Astrid S";
    "ODESZA";
    "Marilyn Manson";
    "Danna Paola";
    "Two Door Cinema Club";
    "Joyner Lucas";
    "Clairo";
    "Bibi und Tina";
    "Mustard";
    "Zoé";
    "Jorja Smith";
    "Tainy";
    "Swedish House Mafia";
    "Pedro Capó";
    "Luciano";
    "Bryant Myers";
    "Colbie Caillat";
    "Luan Santana";
    "Rascal Flatts";
    "Ella Mai";
    "gnash";
    "Martin Jensen";
    "Dolly Parton";
    "Rod Wave";
    "Natanael Cano";
    "Louis Tomlinson";
    "Nacho";
    "Joel Corry";
    "Hardwell";
    "Kontra K";
    "Arizona Zervas";
    "SEVENTEEN";
    "The Smashing Pumpkins";
    "David Bisbal";
    "Maria Becerra";
    "Mike WiLL Made-It";
    "Noriel";
    "Carlos Rivera";
    "MC Kevinho";
    "R. Kelly";
    "The Clash";
    "Kacey Musgraves";
    "Sido";
    "Mac DeMarco";
    "Annie Lennox";
    "3 Doors Down";
    "The Kooks";
    "Desiigner";
    "League of Legends";
    "Sara Bareilles";
    "Cosculluela";
    "MØ";
    "Aitana";
    "Alan Jackson";
    "Lord Huron";
    "Joey Bada$$";
    "Ms. Lauryn Hill";
    "M83";
    "Ali Gatie";
    "Jessie Reyez";
    "KISS";
    "Leon Bridges";
    "Vampire Weekend";
    "Fergie";
    "Owl City";
    "Moneybagg Yo";
    "Bethel Music";
    "Marco Antonio Solís";
    "Wham!";
    "Jaden";
    "DMX";
    "Stefflon Don";
    "Gotye";
    "Olly Murs";
    "Pharrell Williams";
    "Internet Money";
    "Aloe Blacc";
    "Apache 207";
    "Keane";
    "Ha*Ash";
    "OMI";
    "Willy William";
    "Snow Patrol";
    "Chief Keef";
    "Nat King Cole";
    "James TW";
    "Dierks Bentley";
    "Gwen Stefani";
    "Charlie Brown Jr.";
    "MAX";
    "Westlife";
    "Regard";
    "Ciara";
    "Goodboys";
    "Limp Bizkit";
    "Queens of the Stone Age";
    "Sleeping At Last";
    "Kelly Rowland";
    "La Oreja de Van Gogh";
    "Tom Odell";
    "Thirty Seconds To Mars";
    "Mötley Crüe";
    "Nekfeu";
    "Booba";
    "Portugal. The Man";
    "Bill Withers";
    "The Jackson 5";
    "John Newman";
    "Dilsinho";
    "Lofi Fruits Music";
    "Blueface";
    "El Fantasma";
    "Thalia";
    "Loud Luxury";
    "Feid";
    "Trevor Daniel";
    "ANAVITÓRIA";
    "Lee Brice";
    "Santana";
    "Lady A";
    "Ella Fitzgerald";
    "Leona Lewis";
    "girl in red";
    "The Who";
    "Ben Howard";
    "John Lennon";
    "Alice In Chains";
    "Lil Dicky";
    "Old Dominion";
    "Calle 13";
    "Stromae";
    "Michael Silverman";
    "Sade";
    "CHVRCHES";
    "Eladio Carrion";
    "Denzel Curry";
    "Cigarettes After Sex";
    "Ezhel";
    "Gerardo Ortiz";
    "Bruno & Marrone";
    "Saweetie";
    "Daya";
    "Miranda Lambert";
    "Mon Laferte";
    "Brent Faiyaz";
    "Afrojack";
    "Niska";
    "Incubus";
    "Gryffin";
    "Mike Perry";
    "Elevation Worship";
    "Powfu";
    "Tee Grizzley";
    "Sting";
    "Yo Gotti";
    "Los Tigres Del Norte";
    "Roxette";
    "Gigi D'Agostino";
    "Sean Kingston";
    "Seether";
    "MKTO";
    "WILLOW";
    "Taio Cruz";
    "The Pussycat Dolls";
    "Chayanne";
    "Gera MX";
    "Shania Twain";
    "TKKG";
    "Beret";
    "Kollegah";
    "Frédéric Chopin";
    "Wale";
    "Mitski";
    "Kylie Minogue";
    "Darell";
    "AJ Tracey";
    "Summer Cem";
    "Conor Maynard";
    "Ruth B.";
    "fun.";
    "Yung Gravy";
    "Ghostemane";
    "Nipsey Hussle";
    "Bullet For My Valentine";
    "Gente De Zona";
    "Jasmine Thompson";
    "Nas";
    "Otis Redding";
    "Paul Simon";
    "Arcade Fire";
    "Lionel Richie";
    "Die drei !!!";
    "Guaynaa";
    "Surfaces";
    "Jon Pardi";
    "Luísa Sonza";
    "Sufjan Stevens";
    "Chencho Corleone";
    "Nina Simone";
    "The National";
    "KSI";
    "beabadoobee";
    "Los Temerarios";
    "Lily Allen";
    "*NSYNC";
    "Rich Brian";
    "Chase Atlantic";
    "Jack Ü";
    "Felipe Araújo";
    "Greeicy";
    "Wolfgang Amadeus Mozart";
    "Dido";
    "Yusuf / Cat Stevens";
    "Brad Paisley";
    "Ice Cube";
    "Neil Young";
    "Kevin Roldan";
    "IU";
    "Bea Miller";
    "CRO";
    "Kiiara";
    "Martin Solveig";
    "Tears For Fears";
    "Simple Plan";
    "Selena";
    "Banda El Recodo";
    "will.i.am";
    "Ramin Djawadi";
    "Tracy Chapman";
    "Yellow Claw";
    "Cyndi Lauper";
    "Tina Turner";
    "TOMORROW X TOGETHER";
    "Brett Young";
    "Ferrugem";
    "Beastie Boys";
    "Audioslave";
    "KALEO";
    "Jowell & Randy";
    "Olivia O'Brien";
    "Granular";
    "Pineapple StormTv";
    "Lenny Kravitz";
    "Lil Kleine";
    "Sofía Reyes";
    "Alex Rose";
    "LUDMILLA";
    "Chelsea Cutler";
    "DJ Luian";
    "Mary J. Blige";
    "Joaquín Sabina";
    "Electric Light Orchestra";
    "ZZ Top";
    "DENNIS";
    "Blur";
    "Deftones";
    "Natalia Lafourcade";
    "Mc Don Juan";
    "Oh Wonder";
    "Tech N9ne";
    "NCT 127";
    "Dadju";
    "Mambo Kingz";
    "Baby Lullaby Academy";
    "deadmau5";
    "BØRNS";
    "Junior H";
    "Tungevaag";
    "The Goo Goo Dolls";
    "Skepta";
    "Kris Kross Amsterdam";
    "Jay Chou";
    "Tom Walker";
    "La Adictiva Banda San José de Mesillas";
    "Lykke Li";
    "Santa Fe Klan";
    "Alina Baraz";
    "Lauren Daigle";
    "Mr. Probz";
    "Gustavo Cerati";
    "Cher";
    "YUNGBLUD";
    "Spice Girls";
    "The Score";
    "TLC";
    "Tori Kelly";
    "Timbaland";
    "Alvaro Soler";
    "Salmo";
    "Dennis Lloyd";
    "Willie Nelson";
    "Río Roma";
    "Wallows";
    "Lalo Ebratt";
    "Juan Luis Guerra 4.40";
    "Angus & Julia Stone";
    "Gavin James";
    "Falling In Reverse";
    "Bing Crosby";
    "Sasha Alex Sloan";
    "Natiruts";
    "Maggie Lindemann";
    "Lupe Fiasco";
    "Will Smith";
    "Melim";
    "Emeli Sandé";
    "Jack & Jack";
    "Dominic Fike";
    "The Head And The Heart";
    "AURORA";
    "The All-American Rejects";
    "Jeezy";
    "Oliver Tree";
    "Capo Plaza";
    "ZHU";
    "Beck";
    "Pabllo Vittar";
    "Gustavo Mioto";
    "Supertramp";
    "Lil Xan";
    "Pink Sweat$";
    "Nicki Nicole";
    "Diego & Victor Hugo";
    "Thiaguinho";
    "Evaluna Montaner";
    "Matuê";
    "Pixies";
    "Icona Pop";
    "Salaam Remi";
    "Julieta Venegas";
    "Jacquees";
    "Foreigner";
    "Genesis";
    "The Temptations";
    "Simone & Simaria";
    "Sin Bandera";
    "Vince Staples";
    "Duke Dumont";
    "Talking Heads";
    "Brantley Gilbert";
    "Johann Sebastian Bach";
    "Louis Armstrong";
    "Snakehips";
    "Bruno Martini";
    "Laura Pausini";
    "Gloria Trevi";
    "Counting Crows";
    "Oliver Heldens";
    "Grouplove";
    "NEFFEX";
    "Andrea Bocelli";
    "Dustin Lynch";
    "JID";
    "AWOLNATION";
    "Ruel";
    "Giveon";
    "Alanis Morissette";
    "Dean Martin";
    "Benjamin Blümchen";
    "Canserbero";
    "Burna Boy";
    "Megadeth";
    "Gemitaiz";
    "MC Kevin o Chris";
    "Tinie Tempah";
    "Bunbury";
    "RIN";
    "Los Enanitos Verdes";
    "Empire of the Sun";
    "Lil Jon";
    "Missy Elliott";
    "Toby Keith";
    "Pantera";
    "Brett Eldredge";
    "A Tribe Called Quest";
    "Juicy J";
    "Official HIGE DANdism";
    "Dynoro";
    "Marracash";
    "Chris Young";
    "Ultimo";
    "Leonard Cohen";
    "Frenna";
    "MF DOOM";
    "Eurythmics";
    "ONE OK ROCK";
    "Los Bukis";
    "Foals";
    "Kelsea Ballerini";
    "Kina";
    "Dave Matthews Band";
    "Death Cab for Cutie";
    "Gzuz";
    "Sam Cooke";
    "Hungria Hip Hop";
    "KC Rebell";
    "HONNE";
    "Tyler Childers";
    "Ben&Ben";
    "Beach House";
    "Max Richter";
    "Showtek";
    "James Blake";
    "LP";
    "Craig David";
    "Cash Cash";
    "SCH";
    "Timmy Trumpet";
    "Intocable";
    "M.I.A.";
    "MadeinTYO";
    "a-ha";
    "Trueno";
    "Daughtry";
    "Camila";
    "Lindsey Stirling";
    "Chicago";
    "Chet Faker";
    "A R I Z O N A";
    "Micro TDH";
    "Zendaya";
    "Petit Biscuit";
    "No Doubt";
    "The Kinks"
|]

let insertArtist (artist: SearchDesktop.Data3) =

        task {
            let conn = dbConn()
            let cypher = sprintf "CREATE (:Person:Author {name: '%s', id: '%s', img: '%s'})" artist.Profile.Name (getIdFromURI artist.Uri ) artist.Visuals.AvatarImage.Sources[0].Url 
            Console.WriteLine(cypher)
            let! cursor = conn.RunAsync(cypher)
            let! result = cursor.ConsumeAsync()
            let out = result.ToString()
            let! _ = conn.CloseAsync()
            out
        } 

let sayHelloWorld next (ctx: HttpContext) =
        task {
            let! person = ctx.BindJsonAsync<Author>()
            let tasks = Seq.map(fun x -> insertArtist(x),tops)
            return! text "" next ctx    
        }

let readArtists dir = 
    Directory.GetFiles(dir, "*.json") 
         
        |>  Array.Parallel.map (SearchDesktop.Load)
        |> Array.Parallel.map (fun x -> x.Data.SearchV2.Artists.Items[0].Data.Uri 
                                        |> getIdFromURI 
                                        |> queryArtistDiscographyAlbums 
                                        |> run 
                                        |> QueryArtistDiscographyAlbums.Parse 
                                        |> tap(fun y -> File.WriteAllText(x.Data.SearchV2.Artists.Items[0].Data.Uri, y.ToString()))) 


let doMagic next (ctx: HttpContext) =
        task {
            // let artists = Array.Parallel.map(artistByName) tops |> Seq.filter(isOk) |> Seq.map(unwrapResult) 
            
            // Console.WriteLine(artists)
            // let ids = Seq.map(fun (x: SearchDesktop.Data3) -> getIdFromURI(x.Uri ) ) artists 
            // Console.WriteLine(ids)
            let tracks = readDiscographies "/home/davi/gits/FeatOfDistance/discography"
            // let tasks = Array.map(fun x -> insertArtist(x).Wait().ToString()  ,tops) 
            // Console.WriteLine(tasks)

            return! json tracks next ctx
        }
let searchArtist next (ctx: HttpContext) =
        task {
            let term = ctx.Request.Query["term"].ToString().Replace("\"", "sdasd")
            let result = searchDesktop term |> run
            
            return! text result next ctx
        }

let makeQueryHandler query next (ctx: HttpContext) =
      task {
            let term = ctx.Request.Query["term"].ToString().Replace("\"", "")
            let result = query term |> run
            
            return! text result next ctx
        }

let webApp =
    choose [
        route "/ping"   >=> doMagic
        route "/search" >=> makeQueryHandler searchDesktop
        route "/album" >=> makeQueryHandler queryAlbumTracks
        route "/artist" >=> makeQueryHandler queryArtistDiscographyAlbums
        route "/token" >=> text (newToken().ToString())
        route "/"       >=> text "It works!"]


let builder = WebApplication.CreateBuilder()
builder.Services.AddGiraffe() |> ignore
let app = builder.Build()



app.UseGiraffe(webApp)
app.Run()
