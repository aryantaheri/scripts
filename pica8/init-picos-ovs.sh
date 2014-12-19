#!/bin/bash 

mode=$1

brs=$(ovs-vsctl list bridge | grep name | cut -d":" -f2-2 | cut -d"\"" -f2-2)

echo "Setting manager"
ovs-vsctl set-manager tcp:192.168.10.1:6640

for br in $brs ; do
    echo "ovs-vsctl sel-controller $br"
    ovs-vsctl set-controller $br tcp:192.168.10.1:6633
done

if [ "$mode" == "all" ]; then
    for br in $brs ; do

    done
fi
