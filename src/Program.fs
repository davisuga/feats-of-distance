// namespace Main
// module Main =
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
open FSharp.Collections.ParallelSeq

open DomainData.SpotifyResponseTypes
open DomainData.Artists


let toQueryString x =
    let formatElement (pi : PropertyInfo) =
        sprintf "%s=%O" pi.Name <| pi.GetValue x
    x.GetType().GetProperties()
    |> Array.map formatElement
    |> String.concat "&"
    





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
    let groups = Seq.map (fun (x: Group) -> x.Value) (Regex.Match(html,
            "accessToken\":\"(.+?)\"").Groups.Values) |> Seq.first |> Option.get
    {
        token = groups.Replace("accessToken\":\"", "").Replace("\",\"", "").Replace("\"", "")
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
    ["authorization";"Bearer BQCh2rIhjhr_kNYhFoT8P3iszbObiKZNgke9zSG5Rw3F_6qyQIji1AyKuxihQ84s782uHcpLnDrhyKIPlL8"];
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



let dbConn _ = 
    let driver = GraphDatabase.Driver("neo4j://localhost:7687", AuthTokens.Basic("neo4j", "BpWilDx5Ox3wG8NS9OI9FB-F9zYCGmSjJ3aMyOZLTKw"))
    driver.AsyncSession(fun o -> o.WithDatabase("neo4j") |> ignore)

let persistAlbumTracks (tracks:QueryAlbumTracks.Root) =
    tracks.Data.Album.Tracks.Items
    |> PSeq.map  (fun t -> File.WriteAllTextAsync("tracks2/"+t.Track.Uri, t.ToString()).Start())  |> ignore
    tracks
    

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
        logInfo $"tryQueryAlbumTracks with id {id}"
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

let tracePipe message = tap (fun a -> message + " " + a.ToString() |> Console.WriteLine)

let searchTracksForAlbum (album: QueryArtistDiscographyAlbums.Root) =   
    album.Data.Artist.Discography.Albums.Items[0..1]
    |> tracePipe "Items:"
    |> PSeq.collect(fun a -> a.Releases.Items )
    // |> Array.Parallel.map( fun y ->  File.WriteAllText("albums_2"+y.Uri, y.ToString()) |> ignore |> (fun _ -> y))
    |> PSeq.map(fun a -> a.Id )
    |> PSeq.map(tryQueryAlbumTracks [])
    // |> tracePipe "tryQueryAlbumTracks"
    // |> PSeq.collect (fun a -> match a with
    //                                     | Ok x -> getTracks x
    //                                     | Error e -> 
                                        
    //                                     File.AppendAllText("errors", e.ToString())
    //                                     [||]
    //                             )
    // |> PSeq.map( fun y ->  File.WriteAllText("tracks_2/"+y.Track.Uri, y.ToString()) |> ignore |> (fun _ -> y.ToString()))

let readDiscographies dir = 
    Directory.GetFiles(dir, "*.json")[0..1]
    |> PSeq.map (QueryArtistDiscographyAlbums.Load)
    |> PSeq.map searchTracksForAlbum

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
        
        |> PSeq.map (SearchDesktop.Load)
        |> PSeq.map (fun x -> x.Data.SearchV2.Artists.Items[0].Data.Uri 
                                        |> getIdFromURI 
                                        |> queryArtistDiscographyAlbums 
                                        |> run 
                                        |> QueryArtistDiscographyAlbums.Parse 
                                        |> tap(fun y -> File.WriteAllText(x.Data.SearchV2.Artists.Items[0].Data.Uri, y.ToString()))) 


let doMagic next (ctx: HttpContext) =
        task {
            // let artists = PSeq.map(artistByName) tops |> Seq.filter(isOk) |> Seq.map(unwrapResult) 
            
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
        route "/token" >=> text (DomainData.WebAuth.getNewToken |> Option.get)
        route "/"       >=> text "It works!"]


let builder = WebApplication.CreateBuilder()
builder.Services.AddGiraffe() |> ignore
let app = builder.Build()



app.UseGiraffe(webApp)
app.Run()
