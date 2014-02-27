#!/bin/bash

brs=$(ovs-vsctl show | grep "Bridge br"  | awk '{ print $2}')
brs2=$(ovs-vsctl show | grep "Bridge \"br"  | awk '{ print $2}')
qvs=$(ifconfig -a | grep qv | awk '{ print $1}')
qbs=$(ifconfig -a | grep qb | awk '{ print $1}')
taps=$(ifconfig -a | grep tap | awk '{ print $1}')

echo "Cleaning all bridges, remaining virtual interfaces, and removing managers"

echo "ovs-vsctl del-manager"
ovs-vsctl del-manager

echo "deleteing br* bridges"
for br in $brs ; do
    echo "ovs-vsctl del-br $br"
    ovs-vsctl del-br $br
done

for br in $brs2 ; do
    echo "ovs-vsctl del-br $br"
    ovs-vsctl del-br $br
done

echo "deleteing qv* interfaces"
for qv in $qvs ; do
    echo "ip link delete $qv"
    ip link delete $qv
done

echo "deleteing qb* interfaces"
for qb in $qbs ; do
    echo "ip link delete $qb"
    ip link delete $qb
done

echo "deleteing tap* interfaces"
for tap in $taps ; do
    echo "ip link delete $tap"
    ip link delete $tap
done