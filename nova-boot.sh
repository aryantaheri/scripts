#!/bin/bash

# ping retries
((retries = 500))
# ip retrieval retries
((timeout = 200))
((count = $timeout))


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

if [ ! -z "$4" ] ;  then
    outd=$4
    echo 'output dir: ' $outd
fi


if [ ! -z "$5" ] ;  then
    msg=$5
    echo 'Msg: ' $msg
fi


fts=$(date +"%y%m%d-%H%M")
output="$outd/$net-$fts.out"

# loaded from nova
ips="$outd/$net-$fts-ips.list"
# newly found
ips2="$outd/$net-$fts-ips2.list"
# total found
ips3="$outd/$net-$fts-ips3.list"
touch $ips $ips2 $ips3
# nova status list
nova_list="$outd/$net-$fts-nova.list"
nova_manage_list="$outd/$net-$fts-nova-manage.list"

(( nips = 0 ))

# loading subnet IP addr "a.b."0.0
net_ip=$(neutron net-list | grep $net | awk '{ print $7 }' | cut -d'.' -f-2)"\."

# loading previously booted instances
#nova list | grep ACTIVE  | grep = | cut -d'=' -f2- | cut -d' ' -f1 | grep "^$net_ip" > $ips3
neutron port-list  -c id -c name -c mac_address -c fixed_ips -c device_owner | grep -v "network:dhcp" | awk -F'"' '{ print $8}' | grep "^$net_ip" > $ips3
previously_booted=$(cat $ips3 | wc -l)

echo ''
echo 'Booting instances'
echo "nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1 --num-instances $num"
echo ''

if [[ $num -ne 1 ]] ; then
    nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1 --num-instances $num
else 
    nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1
fi

request_time=$(($(date +%s%N)/1000000))
echo "Waiting for IP addresses"

echo "#|Run Name|# instances|# interfaces/instance|# computes|Instance Distribution|Dedicated Bridges Required|Dedicated Bridges Exists|Dedicated Tunnels Exists|Base Tunnels Exists|Tenant Network Type|Input File|" > $output
echo "$msg" >> $output

while [[ $count -ne 0 && $nips -lt $num+$previously_booted ]] ; do

    # nova list | grep ACTIVE  | grep = | cut -d'=' -f2- | cut -d' ' -f1 | grep "^$net_ip" | cut -d',' -f1-1 > $ips
    neutron port-list -c id -c name -c mac_address -c fixed_ips -c device_owner | grep -v "network:dhcp" | awk -F'"' '{ print $8}' | grep "^$net_ip" > $ips
    nips=$(cat $ips | wc -l)
    comm -13 <(sort $ips3) <(sort $ips) > $ips2
    cat $ips2 >> $ips3

    if [[ $nips -lt $num+$previously_booted ]] ; then
        echo "WARN: Number of instances with  $net_ip $nips is not equal to the number of requested instances $num plus previously booted instances $previously_booted"
    fi
    if [[ $nips -gt $num+$previously_booted ]] ; then
        echo "ERROR: Number of instances with  $net_ip $nips is BIGGER than the number of requested instances $num plus previously booted instances $previously_booted"
    fi
    

    while read -r ip; do
	echo "Checking ${ip} reachability"
	./ping-reachability.sh $ip $retries "qdhcp-$net" $request_time $output &
    done < "$ips2"
    (( count = count - 1 ))
#    if (( $count < 20 )) ; then
    sleep $(expr $timeout - $count)
#    fi

done

echo "nova list" > $nova_list
nova list >> $nova_list

echo "nova-manage vm list" >> $nova_list
nova-manage vm list >> $nova_list

echo "neutron port-list | grep ^$net_ip" >> $nova_list
#neutron port-list | awk -F'"' '{ print $8}' | grep "^$net_ip" >> $nova_list
cat  $ips >> $nova_list

echo "neutron port-list"  >> $nova_list
neutron port-list -c id -c name -c mac_address -c fixed_ips -c device_owner >> $nova_list

rm $ips $ips2 $ips3