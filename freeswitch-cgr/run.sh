#!/bin/bash

set -e

[[ -f /etc/entrypoint ]] && . /etc/entrypoint
[[ -f /etc/default/$APP ]] && . /etc/default/$APP

# options: debug info notice warning err crit alert console
: readonly ${FREESWITCH_LOG_LEVEL:=info}
: readonly ${FREESWITCH_LOG_COLOR:=true}

# RTP port range settings
: declare -ir ${FREESWITCH_RTP_START_PORT:=16384}
: declare -ir ${FREESWITCH_RTP_END_PORT:=32768}

# if true, sets -nonat flag on freeswitch
: readonly ${FREESWITCH_DISABLE_NAT_DETECTION:=true}

: readonly ${FREESWITCH_SEND_ALL_HEADERS:=true}

# settings for sipcapture
: readonly ${FREESWITCH_CAPTURE_SERVER:=false}
: readonly ${FREESWITCH_CAPTURE_IP:=127.0.0.1}

# Enable TLS here
: readonly ${FREESWITCH_TLS_ENABLE:=false}

PUBLIC_IP="$(curl ipinfo.io/ip)"
echo "public ip: $PUBLIC_IP"
echo "Setting public ip on freeswitch profile..."
sed -i 's#<X-PRE-PROCESS cmd="set" data="external_sip_ip=auto"/>#<X-PRE-PROCESS cmd="set" data="external_sip_ip='$PUBLIC_IP'"/>#g' /etc/freeswitch/freeswitch.xml
sed -i 's#<X-PRE-PROCESS cmd="set" data="external_rtp_ip=auto"/>#<X-PRE-PROCESS cmd="set" data="external_rtp_ip='$PUBLIC_IP'"/>#g' /etc/freeswitch/freeswitch.xml

echo "Setting $APP log level $FREESWITCH_LOG_LEVEL ..."
tee /etc/freeswitch/autoload_configs/console.conf.xml <<EOF
<configuration name="console.conf" description="Console Logger">
    <settings>
        <param name="colorize" value="$FREESWITCH_LOG_COLOR"/>
        <param name="loglevel" value="${FREESWITCH_LOG_LEVEL,,}"/>
    </settings>
    <mappings>
        <map name="all" value="console,debug,info,notice,warning,err,crit,alert"/>
    </mappings>
</configuration>
EOF

if [[ $FREESWITCH_CAPTURE_SERVER = true ]]; then
    echo "Enabling capture server ..."
    sed -i "/global_settings/a \
        \       <param name=\"capture-server\" value=\"udp:${FREESWITCH_CAPTURE_IP}:9060;hep=3;capture_id=200\"/>" /etc/freeswitch/autoload_configs/sofia.conf.xml
    grep capture-server $_

    sed -i "/<!-- SIP -->/a \
        \       <param name=\"sip-capture\" value=\"yes\"/>" /etc/freeswitch/sip_profiles/sipinterface_1.xml
    grep sip-capture $_
fi

echo "Setting RTP Port Range Min/Max on switch.conf.xml ..."
sed -i "/rtp-start-port/s/value=\".*\"/value=\"$FREESWITCH_RTP_START_PORT\"/" /etc/freeswitch/autoload_configs/switch.conf.xml
sed -i "/rtp-end-port/s/value=\".*\"/value=\"$FREESWITCH_RTP_END_PORT\"/" $_
grep 'rtp-' $_


echo "Ensuring volume dirs ..."
mkdir -p /volumes/ram/{log,run,db,cache,http_cache}


echo "Setting ulimits ..."
set-limits freeswitch


if linux::cap::is-disabled 'net_raw'; then
    linux::cap::show-warning 'net_raw'
fi


echo "Ensuring permissions ..."
chown -R $USER:$USER ~ /etc/freeswitch
fixattrs


echo "Building arguments ..."
CMD_ARGS=(-c -rp -nf -u $USER -g $USER)
[[ $FREESWITCH_DISABLE_NAT_DETECTION = true ]] && \
    CMD_ARGS+=(-nonat)
set -- ${CMD_ARGS[@]}


echo "Starting $APP ..."
cd ~
    gosu $USER epmd -daemon
    exec freeswitch "$@" 2>&1