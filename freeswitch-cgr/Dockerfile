FROM callforamerica/freeswitch

MAINTAINER Gabriele Proni <me@gabrieleproni.com>

COPY sip_profiles /etc/freeswitch/sip_profiles/
COPY dialplan /etc/freeswitch/dialplan/
COPY autoload_configs /etc/freeswitch/autoload_configs/
COPY freeswitch.xml /etc/freeswitch/freeswitch.xml
COPY run.sh /

WORKDIR /

SHELL       ["/bin/bash"]
ENTRYPOINT  ["/dumb-init", "--"]
CMD         ["bash","run.sh"]
