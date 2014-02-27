#!/bin/bash

qvs=$(ifconfig -a | grep qv | awk '{ print $1}')
qbs=$(ifconfig -a | grep qb | awk '{ print $1}')
taps=$(ifconfig -a | grep tap | awk '{ print $1}')

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