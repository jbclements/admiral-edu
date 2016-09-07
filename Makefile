
ConfPath = $(shell pwd)/conf

TAG = captain-teach:latest

RUN = docker run --name captain_teach -i -t -v $(ConfPath):/conf --rm -p 8080:8080 $(TAG)

all:
	docker build -t $(TAG) .

run: all
	$(RUN)

bash: all
	$(RUN) /bin/bash

