FROM debian:8.5
MAINTAINER John Clements <aoeudocker@brinckerhoff.org>

WORKDIR /root
USER root

RUN echo "tmp"
RUN apt-get update

RUN apt-get install -y wget


ENV DEBIAN_FRONTEND noninteractive

#
# Install Racket
#

RUN wget https://mirror.racket-lang.org/installers/6.6/racket-6.6-x86_64-linux.sh

RUN sh ./racket-6.6-x86_64-linux.sh

RUN ln -s /usr/racket/bin/racket /usr/local/bin/racket
RUN ln -s /usr/racket/bin/raco /usr/local/bin/raco


# Setup Captain Teach Server

# Create User
RUN adduser --disabled-password --gecos "" admiraledu

# Install Captain Teach Server

## install aws manually to get a version that uses old V2 AWS signatures.
## delete this line when the aws package works with google cloud storage.
RUN raco pkg install --no-setup --auto git://github.com/greghendershott/aws#f1bd5f7736b787fd407ad39e1dd567df4e241191
RUN raco setup --no-docs aws

## NOTE: switching away from catalog lookup temporarily...
RUN raco pkg install --no-setup --auto git://github.com/jbclements/admiral-edu-server#3c48db0a8f2c10cea4dc3d66fd2fe9e005e29f10
# RUN raco pkg install --auto admiral-edu-server
RUN raco setup --no-docs admiral-edu

#
# Install supervisord
#
RUN apt-get install -y supervisor

#
# Install zip / unzip utilities
#
RUN apt-get install -y zip unzip

RUN mkdir -p /home/admiraledu/files
RUN chown admiraledu /home/admiraledu/files
RUN chgrp admiraledu /home/admiraledu/files

#
# Copy Captain Teach Scripts, Images, CSS
#
ADD html/bin /var/www/html/bin
ADD html/css /var/www/html/css
ADD html/imgs /var/www/html/imgs
ADD code-mirror/mode /var/www/html/mode
ADD code-mirror/lib /var/www/html/lib
ADD html/logout.html /var/www/html/logout.html

#
# Configure Supervisor
#
ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#
# Add Debug Script
#
ADD docker/debug.sh /root/debug.sh
RUN chmod +x /root/debug.sh

#
# Add some default rubrics for testing purposes
#
ADD rubrics/implementation-rubric.json /home/admiraledu/reviews/cmpsci220/clock/implementation/rubric.json
ADD rubrics/tests-rubric.json /home/admiraledu/reviews/cmpsci220/clock/tests/rubric.json

ADD html/index.html /var/www/html/index.html

#
# Run AdmiralEdu
#

CMD supervisord
