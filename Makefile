include .env.local
export
LOGPATH = ./backend/logs
LOGFILE = $(LOGPATH)/$(shell date --iso=seconds)

install-deps:
	cd ./backend && opam install cmdliner re2 dream redis redis-lwt cohttp cohttp-lwt-unix uri 

start:
	echo "./backend/_build/default/bin/main.exe --verbose  > >(tee -a $(LOGFILE)_stdout.log) 2> >(tee -a $(LOGFILE)_stderr.log >&2)" | bash

build-watch:
	cd ./backend && dune build -w && cd ..

build-prod:
	cd ./backend; dune build --profile production; cd ..

copy-build:
	rm -rf ./backend/main.exe; cp ./backend/_build/default/bin/main.exe ./backend

redeploy-heroku: build-prod copy-build
	git add ./backend/main.exe; git commit -m "redeploy"; git push heroku main

client-gen-types:
	cd ./client/packages/app && yarn gen

web-start:
	cd ./client/ && yarn web
utop:
	cd ./backend && dune utop
be-test:
	cd ./backend && dune runtest

be-test-watch:
	cd ./backend && dune runtest -w
db-start:
	docker run -it \--name testneo4j \
    --publish=7474:7474 --publish=7687:7687 \
    -v $HOME/neo4j/data:/data \
    -v $HOME/neo4j/logs:/logs \
    -v $HOME/neo4j/import:/var/lib/neo4j/import \
    -v $HOME/neo4j/plugins:/plugins \
    --env NEO4J_AUTH=none \
    -e NEO4J_apoc_export_file_enabled=true \
    -e NEO4J_apoc_import_file_enabled=true \
    -e NEO4J_apoc_import_file_use__neo4j__config=true \
    -e NEO4JLABS_PLUGINS=\[\"apoc\"\] neo4j:4.3

azure-deploy: build-prod copy-build
	func azure functionapp publish featsOfDistance 

azure-start-local:copy-build
	func start
	
spotify-client-sdk:
	$(JAVA_HOME)/bin/java -jar openapi-generator-cli-6.0.1.jar generate -i spotify-openapi.yml -g typescript-axios -o ./client/packages/app/spotify-client --skip-validate-spec