# Feats Of Distance

Finds how distant are your favorite artists!

## How to run the backend

Requirements:

- Opam
- OCaml
- Esy
- Golang (optional, only needed to patch the neo4j-caller)

Install OCaml dependencies with `make install-deps`

Start the API with `make start`

## Testing

Test the backend with `make be-test`

## How to run the frontend

Requirements:

- NPM
- Node
- Java (optional, only needed to generate types)
  Install dependencies: `cd client && npm install`

Generate the GraphQL client: `make client-gen-types`

...and the Spotify API bindings: `make spotify-client-sdk`

To generate the types, the backend must be running.

## Todo:

- [ ] Finish the frontend: We have a barely functional frontend, but it's far from pretty. Expected design: https://www.figma.com/file/BXcff0JH6geY6x3A1ACttZ/projects?node-id=201%3A78

- [ ] Setup CI and CD in a great cloud. It already works with Heroku, but would be better if we could keep it running (like in Fly.io) without sleeping every time. It was deployed on a VPS too, but redeploying takes some effort.

- [ ] Make it work with a bigger database: It currently uses Neo4j Aura, which only support up to 200K nodes and we want to have at least 1M artists to consult. 
TigerGraph would be able to up to 50GB, but the instance goes down when we try to import some data.
CosmosDB supports 5 GB, but I'm not sure if its enough