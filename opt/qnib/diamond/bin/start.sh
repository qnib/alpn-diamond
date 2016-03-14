#!/usr/local/bin/dumb-init /bin/bash

if [ "X${COLLECT_METRICS}" != "Xtrue" ];then
    echo "Do not start metrics collector (COLLECT_METRICS != true)"
    rm -f /etc/consul.d/diamond.json
    sleep 1
    consul reload
    exit 0
fi

PIDFILE=/var/run/diamond.pid


for collector in $(echo ${DIAMOND_COLLECTORS} |tr ',' ' ');do 
    if [ -f /etc/diamond/collectors/${collector}.conf.disabled ];then
        ln -sf /etc/diamond/collectors/${collector}.conf.disabled /etc/diamond/collectors/${collector}.conf
    fi
done
## Wait for consul to start
sleep 5

consul-template -consul localhost:8500 -once -template "/etc/consul-templates/diamond/diamond.conf.ctmpl:/etc/diamond/diamond.conf"

diamond -f -l
