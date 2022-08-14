# FROM ubuntu:18.04

# RUN apt-get update
# RUN apt-get install -y libssl1.1 libev4
# RUN apt-get install netbase
# COPY ./main.exe main.exe
# COPY ./golang/neo4j-caller neo4j-caller
# ENV PORT 8080

# EXPOSE 8080

# CMD ["./main.exe"]
FROM ocaml/opam:alpine as build

# Install system dependencies
RUN sudo apk add --update libev-dev openssl-dev

WORKDIR /home/opam

# Install dependencies
ADD featsOfDistance.opam featsOfDistance.opam
RUN opam install . --deps-only

# Build project
ADD . .
RUN opam exec -- dune build

FROM alpine:3.12 as run

RUN apk add --update libev

COPY --from=build /home/opam/_build/default/main.exe /bin/main

ENTRYPOINT /bin/main
