#!/bin/bash

((retries = 100))



if [ ! -z "$1" ] ;  then
    image=$1
    echo 'Image UUID is: ' $image
fi

if [ ! -z "$2" ] ;  then
    net=$2
    echo 'Net UUID is: ' $net
fi
if [ ! -z "$3" ] ;  then
    num=$3
    echo 'Number of requested instances is: ' $num
fi


outd="./report/"
if [ ! -d "$outd" ] ; then
    mkdir $outd
fi

output="$outd/$net.out"

echo ''
echo 'Booting instances'
echo "nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1 --num-instances $num"
echo ''

#nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1 --num-instances $num

echo "Waiting for IP addresses"

ips=$(nova list | grep ACTIVE  | grep = | cut -d'=' -f2- | cut -d' ' -f1)

nips=$(echo $ips | wc -w)

if [[ $nips -ne $num ]] ; then
    echo "WARN: Number of instances with IP $nips is not equal to the number of requested instances $num"
fi

#for ip in "$ips"; do
#  echo "Checking ${ip} reachability"
#  ./ping-reachability.sh $ip $retries "qdhcp-$net" $output
#done

while read -r ip; do
    echo "Checking ${ip} reachability"
    ./ping-reachability.sh $ip $retries "qdhcp-$net" $output
done <<< "$ips"

