#!/bin/bash

# A simple script to collect NIC byte & error counts on 10G interfaces
# Only works with AHV
# Collects: driver version, ring params, rx/tx & error counts and lldpctl for switch connection details

# run on a CVM
# Limitation: only works with AHV.

function allssh () 
{ 
    CMDS=$@;
    DEFAULT_OPTS="-q -o LogLevel=ERROR -o StrictHostKeyChecking=no";
    EXTRA_OPTS=${ALLSSH_OPTS-"-t"};
    OPTS="$DEFAULT_OPTS $EXTRA_OPTS";
    for i in `svmips`;
    do
        if [ "x$i" == "x$IP" ]; then
            continue;
        fi;
        echo "================== "$i" =================";
        /usr/bin/ssh $OPTS $i "source /etc/profile;$@";
    done;
    echo "================== "$IP" =================";
    /usr/bin/ssh $OPTS $IP "source /etc/profile;$@"
}

echo -n "Run started at : "
date
allssh 'ssh root@192.168.5.1 lldpctl; for n in $(manage_ovs show_interfaces | grep 10000 | grep True |  cut -c -4); do echo "===== $n ====="; ssh root@192.168.5.1 ethtool -i $n; ssh root@192.168.5.1 ethtool -g $n; ssh root@192.168.5.1 ethtool -S $n | egrep "[tr]x_packets|[tr]x_bytes|rx_missed_errors|rx_no_buffer_count|[rt]x_flow_control"; done'

echo -n "Run finished at : "
date

