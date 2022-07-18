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
