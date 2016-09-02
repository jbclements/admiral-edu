FROM debian:8.5
MAINTAINER John Clements <aoeudocker@brinckerhoff.org>

WORKDIR /root
USER root

RUN apt-get update #force rerun

RUN apt-get install -y wget


ENV DEBIAN_FRONTEND noninteractive

#
# Install Apache
#

RUN apt-get install -y apache2

#
# Install mod_auth_openidc
#

# Dependencies
RUN apt-get install -y libcurl3 libjansson4

#RUN wget https://github.com/pingidentity/mod_auth_openidc/releases/download/v1.3/libapache2-mod-auth-openidc_1.3_amd64.deb
RUN wget https://github.com/pingidentity/mod_auth_openidc/releases/download/v1.5/libapache2-mod-auth-openidc_1.5_amd64.deb
#RUN wget https://github.com/pingidentity/mod_auth_openidc/releases/download/v1.5.3/libapache2-mod-auth-openidc_1.5.3-2_amd64.deb
RUN dpkg -i libapache2-mod-auth-openidc_1.5_amd64.deb

#
# Configure Apache
#

RUN a2enmod auth_openidc
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod ssl

#
# Install supervisord
#
RUN apt-get install -y supervisor


#######################################################################
# Add captain-teach apache configuration file
# This file specifies how the user is authenticated
# Note: You need to modify this file
#######################################################################
ADD docker/captain-teach-proxy.conf /etc/apache2/conf-available/captain-teach.conf

RUN a2enconf captain-teach

#
# Copy Captain Teach Scripts, Images, CSS
#
ADD html/bin /var/www/html/bin
ADD html/css /var/www/html/css
ADD html/imgs /var/www/html/imgs
ADD html/images var/www/html/images
ADD code-mirror/mode /var/www/html/mode
ADD code-mirror/lib /var/www/html/lib
ADD html/logout.html /var/www/html/logout.html
ADD docker/500.html /var/www/html/500.html
ADD docker/503.html /var/www/html/503.html
ADD docker/auth.html /var/www/html/auth/index.html
Add author-tool/AuthoringTool.html /var/www/html/AuthoringTool.html
#
# Configure Supervisor
#
ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#
# Apache fails to start on install since it has unbound variables. That puts
# it into an inconsistent state. The line below cleans up.
#
RUN service apache2 start; service apache2 stop

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
ADD html/about.html /var/www/html/about.html

#
# Run AdmiralEdu
#

CMD supervisord
