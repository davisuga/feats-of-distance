#r "nuget: FSharp.Data"
#r "nuget: Gremlin.Net, 3.4.13"
#r "nuget: Gremlin.Net.Extensions"
#r "nuget: Microsoft.Extensions.Configuration.Json"
#r "nuget: Microsoft.Azure.Cosmos, 3.23.0"

open System
open System.IO
open System.Collections.Generic
open System.Threading.Tasks
open FSharp.Data
open Microsoft.Azure.Cosmos

let connectionString = "<Your-CosmosDB-Connection-String>"
let databaseName = "TestDb"
let containerName = "TestColl"
let partitionKey = "pk"

type ArtistCsv = CsvProvider<"./artist.csv">
type TrackCsv = CsvProvider<"./tracks.csv">

let generateVertices (artistCsvData: seq<ArtistCsv.Row>) (trackCsvData: seq<TrackCsv.Row>) =
    seq {
        for artist in artistCsvData do
            let v = new GremlinVertex(artist.Artist_id, "artist")
            v.AddProperty(partitionKey, artist.Artist_id)
            v.AddProperty("name", artist.Artist_name)
            yield v

        for track in trackCsvData do
            let v = new GremlinVertex(track.Id, "track")
            v.AddProperty(partitionKey, track.Id)
            v.AddProperty("name", track.Name)
            yield v
    }

let generateEdges (featuresRelations: seq<string * string * string>) =
    seq {
        for (artistA, artistB, songId) in featuresRelations do
            let e = new GremlinEdge(
                songId, 
                "features", 
                artistA, 
                artistB, 
                "artist", 
                "artist", 
                artistA, 
                artistB)
            e.AddProperty("song_id", songId)
            yield e
    }

let readCsvData () =
    let artistCsvData = ArtistCsv.GetSample().Rows
    let trackCsvData = TrackCsv.GetSample().Rows
    (artistCsvData, trackCsvData)

let main =
    async {
        let cosmosClient = new CosmosClient(connectionString)
        let! database = cosmosClient.CreateDatabaseIfNotExistsAsync(databaseName) |> Async.AwaitTask
        do! database.CreateContainerIfNotExistsAsync(containerName, sprintf "/%s" partitionKey, 10000) |> Async.AwaitTask
        
        let graphBulkExecutor = new GraphBulkExecutor(connectionString, databaseName, containerName)

        let artistCsvData, trackCsvData = readCsvData()
        let vertices = generateVertices artistCsvData trackCsvData
        let edges = generateEdges featuresRelations

        let gremlinElements = new List<IGremlinElement>()
        gremlinElements.AddRange(vertices)
        gremlinElements.AddRange(edges)

        let! bulkOperationResponse = graphBulkExecutor.BulkImportAsync(gremlinElements, true) |> Async.AwaitTask
        printfn "TotalTimeTaken: %A" bulkOperationResponse.TotalTimeTaken
        printfn "TotalRequestUnitsConsumed: %A" bulkOperationResponse.TotalRequestUnitsConsumed
        printfn "SuccessfulDocuments: %A" bulkOperationResponse.Successful
        printfn "SuccessfulDocuments: %A" bulkOperationResponse.SuccessfulDocuments
    }

// Start the main async workflow
main |> Async.RunSynchronously
