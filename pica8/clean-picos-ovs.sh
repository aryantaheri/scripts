#!/bin/bash 

mode=$1

echo "Deleting br-int"
ovs-vsctl del-br br-int

brs=$(ovs-vsctl list bridge | grep name | cut -d":" -f2-2 | cut -d"\"" -f2-2)

echo "Deleting manager"
ovs-vsctl del-manager

for br in $brs ; do
    echo "ovs-vsctl del-controller $br"
    ovs-vsctl del-controller $br
    echo "ovs-ofctl del-flows $br"
    ovs-ofctl del-flows $br
    echo "ovs-ofctl del-meter $br"
    ovs-ofctl del-meter $br
done

if [ "$mode" == "all" ]; then
    for br in $brs ; do
	echo "ovs-vsctl del-br $br"
	ovs-vsctl del-br $br
	ovs-vsctl clear port ge-1/1/2 qos
	ovs-vsctl clear port ge-1/1/3 qos
	ovs-vsctl clear port ge-1/1/4 qos
	ovs-vsctl clear port ge-1/1/5 qos
	ovs-vsctl - --all destroy qos
	ovs-vsctl - --all destroy queue
    done
fi
