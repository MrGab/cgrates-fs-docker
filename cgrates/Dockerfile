FROM debian:jessie

MAINTAINER Gabriele Proni <me@gabrieleproni.com>

COPY run.sh /run.sh
COPY installer.deb /installer.deb
COPY import_tariffplan.sh /import_tariffplan.sh

WORKDIR /

# apt-get requisites
RUN apt-get update && apt-get install -y rsyslog netcat-traditional net-tools && rm -rf /var/lib/apt/lists/* && chmod a+rx /run.sh && chmod a+rx /import_tariffplan.sh

#install cgrates
RUN dpkg -i installer.deb

# cgrates config file and set mysql credentials
COPY cgrates.json /etc/cgrates

# expose JSON-RPC over HTTP
EXPOSE 2080

# entrypoint
ENTRYPOINT ["/run.sh"]
