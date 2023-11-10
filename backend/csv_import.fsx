#r "nuget: FSharp.Data"
#r "nuget: Gremlin.Net, 3.4.13"
#r "nuget: Gremlin.Net.Extensions"
#r "nuget: Microsoft.Extensions.Configuration.Json"
#r "nuget: Microsoft.Azure.Cosmos"
#r "nuget: Microsoft.Azure.CosmosDB.BulkExecutor"

// #r "nuget: Azure"
// open System.IO
// open FSharp.Data
// Microsoft.Azure.Documents.Client, Version=2.5.1.0
// open Gremlin.Net.Driver;
// open Gremlin.Net.Driver.Exceptions;
// open Gremlin.Net.Structure.IO.GraphSON;
// open Gremlin.Net.Extensions
// open Gremlin.Net.Process.Traversal
// let g = AnonymousTraversalSource.Traversal()

// Learn more about F# at http://fsharp.org
type AzureCosmosDbConfiguration =
    {
        Hostname: string
        Port: int
        AuthKey: string
        Username: string
        GraphName: string
    }
open System
open System.Collections.Generic
open System.Net.WebSockets
open Gremlin.Net.Driver
open Gremlin.Net.Driver.Exceptions
open Gremlin.Net.Structure.IO.GraphSON
open Newtonsoft.Json
open FSharp.Data
open System.IO
open Microsoft.Azure.Cosmos
// module DotEnv =
//     open System
//     open System.IO

//     let private parseLine(line : string) =
//         Console.WriteLine (sprintf "Parsing: %s" line)
//         match line.Split('=', StringSplitOptions.RemoveEmptyEntries) with
//         | args when args.Length = 2 ->
//             Environment.SetEnvironmentVariable(
//                 args.[0],
//                 args.[1])
//         | _ -> ()

//     let private load() =
//         lazy (
//             Console.WriteLine "Trying to load .env file..."
//             let dir = Directory.GetCurrentDirectory()
//             let filePath = Path.Combine(dir, ".env")
//             filePath
//             |> File.Exists
//             |> function
//                 | false -> Console.WriteLine "No .env file found."
//                 | true  ->
//                     filePath
//                     |> File.ReadAllLines
//                     |> Seq.iter parseLine
//         )

//     let init = load().Value
type AuthorRelation = CsvProvider<"/Users/davi/Documents/features.csv">
type Artists = CsvProvider<"/Users/davi/Documents/artists.csv">
type Tracks = CsvProvider<"/Users/davi/Documents/tracks.csv">

type Feature = {
    artistAId: string
    songId: string
    artistBId: string
}
let featuresRelations _ =
    AuthorRelation.GetSample().Rows
    |> Seq.groupBy (fun row -> row.Song_id)
    |> Seq.collect (fun (songId, artists) ->
        let artistPairs =
            artists 
            |> Seq.map (fun x -> x.Artist_id)
            |> Seq.toArray
            |> fun arr -> [ for i in 0 .. (arr.Length - 2) do
                              for j in (i + 1) .. (arr.Length - 1) -> (arr.[i], arr.[j]) ]
        artistPairs
        |> Seq.map (fun (artistA, artistB) -> { artistAId = artistA; songId = songId; artistBId = artistB })
    )
    |> Seq.distinctBy (fun feat -> feat.artistAId + feat.artistBId)


// DotEnv.init
module GremlinNetSample =
    open Microsoft.Azure.Cosmos
    open Microsoft.Azure.Documents.Client

    // Azure Cosmos DB Configuration variables
    // Replace the values in these variables to your own.
    let invalidArg = invalidArg "Error: "
    let getEnv key =
        match Environment.GetEnvironmentVariable(key) |> Option.ofObj with
        | Some value -> value
        | None -> invalidArg (sprintf "Missing env var: %s" key)
    let primaryKey = getEnv("PrimaryKey")
    let database = getEnv("DatabaseName")
    let connectionString = getEnv("ConnectionString")

    let container = getEnv("GraphName")
    let host = getEnv("Host")
    let enableSSL =
        match Boolean.TryParse(getEnv("Ssl")) with
        | (true, parsedValue) -> parsedValue
        | _ -> true
        
    let port =
        match Int32.TryParse(getEnv("Port")) with
        | (true, parsedValue) -> parsedValue
        | _ -> 433
        
   
    let getValueAsString (dictionary: IReadOnlyDictionary<string, obj>) key =
        JsonConvert.SerializeObject(dictionary.[key])

    let getValueOrDefault (dictionary: IReadOnlyDictionary<string, obj>) key =
        if dictionary.ContainsKey(key) then
            dictionary.[key]
        else
            null

    // let printStatusAttributes (attributes: IReadOnlyDictionary<string, obj>) =
    //     Console.WriteLine $"\tStatusAttributes:"
    //     Console.WriteLine $"\t[\"x-ms-status-code\"] : {getValueAsString attributes "x-ms-status-code"}"
    //     Console.WriteLine $"\t[\"x-ms-total-server-time-ms\"] : {getValueAsString attributes "x-ms-total-server-time-ms"}"
    //     Console.WriteLine $"\t[\"x-ms-total-request-charge\"] : {getValueAsString attributes "x-ms-total-request-charge"}"

    let submitRequest (gremlinClient: GremlinClient) (query: KeyValuePair<string,string>) = 
        async {
            try
                let! resultSet = gremlinClient.SubmitAsync<obj>(query.Value) |> Async.AwaitTask
                return resultSet
            with
            | :? ResponseException as e ->
                Console.WriteLine("\tRequest Error!")
                Console.WriteLine($"\tStatusCode: {e.StatusCode}")
                // printStatusAttributes e.StatusAttributes
                // Console.WriteLine($"\t[\"x-ms-retry-after-ms\"] : {getValueAsString e.StatusAttributes "x-ms-retry-after-ms"}")
                // Console.WriteLine($"\t[\"x-ms-activity-id\"] : {getValueAsString e.StatusAttributes "x-ms-activity-id"}")
                return raise e
        }

    let main () =
        let containerLink = $"/dbs/{database}/colls/{container}"
        let cosmosClient = new CosmosClient(connectionString)

        (task {
            let! db = (cosmosClient.CreateDatabaseIfNotExistsAsync(database))
            let! c = db.Database.CreateContainerIfNotExistsAsync(container, "/primaryKey")
            c.Container.CreateItemAsync({| id = "1"; name = "davi" |}, new PartitionKey("1")).Wait()
            // Artists.GetSample().Rows |> Seq.iter (fun row ->
            //     let artist = { id = row.Artist_id; name = row.Artist_name }
            //     let! _ = c.Container.CreateItemAsync(artist, new PartitionKey(artist.id))
            //     return ()
            // )
            return ()
        }).Wait()
        ()

        // Console.WriteLine($"Connecting to: host: {host}, port: {port}, container: {containerLink}, ssl: {enableSSL}")
        // let gremlinServer = GremlinServer(host, port, enableSSL, containerLink, primaryKey)

        // let connectionPoolSettings = ConnectionPoolSettings(
        //     MaxInProcessPerConnection = 10,
        //     PoolSize = 30,
        //     ReconnectionAttempts = 3,
        //     ReconnectionBaseDelay = TimeSpan.FromMilliseconds(500))

        // let webSocketConfiguration = fun (options: ClientWebSocketOptions) ->
        //     options.KeepAliveInterval <- TimeSpan.FromSeconds(10)

        // use gremlinClient = new GremlinClient(gremlinServer, GraphSON2Reader(), GraphSON2Writer(), GremlinClient.GraphSON2MimeType, connectionPoolSettings, webSocketConfiguration)

        // for query in gremlinQueries do
        //     Console.WriteLine($"Running this query: {query.Key}: {query.Value}")
        //     let resultSet = submitRequest gremlinClient query |> Async.RunSynchronously
        //     if resultSet.Count > 0 then
        //         Console.WriteLine("\tResult:")
        //         for result in resultSet do
        //             let output = JsonConvert.SerializeObject(result)
        //             Console.WriteLine($"\t{output}")
        //         Console.WriteLine()

        //     // printStatusAttributes resultSet.StatusAttributes
        //     Console.WriteLine()

        // Console.WriteLine("Done. Press any key to exit...")
        // Console.ReadLine()

    main()