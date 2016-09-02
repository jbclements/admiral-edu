
ConfPath = $(shell pwd)/conf

LogPath = $(shell pwd)/log

TAG = captain-teach:latest

RUN = docker run --name captain-teach -i -t -v $(ConfPath):/conf --rm -p 443:443 -p 80:80 $(TAG)

all:
	docker build -t $(TAG) .

run: all
	$(RUN)

bash: all
	$(RUN) /bin/bash

debug: all
	$(RUN) ./debug.sh

proxy: all
	docker run --name captain-teach -i -t -v $(ConfPath):/conf -v $(LogPath):/var/log -p 443:443 -p 80:80 $(TAG)
