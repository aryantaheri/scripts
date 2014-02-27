#!/bin/bash

from=$1
to=$2

cidr="172.16"
netmask="24"
# eth1 ip address: 255.255.255.x
# network num: a
# interface ip address: 172.16.a.x

x=$(ip a show eth1  | sed -nr 's/.*inet (addr:)?(([0-9]*\.){3}([0-9]*)).*/\4/p')
output="/etc/network/interfaces"

## append template to /etc/network/interfaces
#iface ex-secnet1 inet manual
#     up ip link set up dev ex-secnet1
#     up ip addr add 192.168.1.21/24 brd + dev ex-secnet1
##     up ip route add default via w.x.y.z dev ex-secnet1
#     down ip addr del 192.168.1.21/24 dev ex-secnet1
#     down ip link set down dev ex-secnet1
for a in $(seq $from $to); do
    echo $a
    ipa="$cidr.$a.$x/$netmask"
    echo $ipa

    echo "" >> $output
    echo "#--------- Virtual Interfaces for OS+ODL Dedicated Bridges ---------#" >> $output
    echo "iface ex-secnet$a inet manual"  >> $output
    echo "     up ip link set up dev ex-secnet$a" >> $output
    echo "     up ip addr add $ipa brd + dev ex-secnet$a"  >> $output
    echo "#     up ip route add default via w.x.y.z dev ex-secnet$a"  >> $output
    echo "     down ip addr del $ipa dev ex-secnet$a"  >> $output
    echo "     down ip link set down dev ex-secnet$a"  >> $output
    echo ""  >> $output
done
