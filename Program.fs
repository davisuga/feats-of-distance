open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.Hosting
open Giraffe
let webApp =
    choose [
        route "/ping"   >=> text "pong"
        route "/"       >=> text "It works!"]


let builder = WebApplication.CreateBuilder()
builder.Services.AddGiraffe() |> ignore
let app = builder.Build()

app.UseGiraffe(webApp)
app.Run()