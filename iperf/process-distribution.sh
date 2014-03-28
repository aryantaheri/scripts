#!/bin/bash

if [ ! -z "$1" ] ;  then
    reports=$1
    echo 'Reports dir is: ' $reports
else 
    echo "Usage: $0 REPORT_FOLDER"
    exit 1
fi

nxlists="$reports/*.list"

declare -a computes=("haisen13" "haisen14" "haisen15" "haisen16" "haisen17")

#each represent a subexperiment, for a specific number of networks
for nxlist in $nxlists ; do
    echo "nX.list $nxlist"
    num_instances=$(echo $nxlist | grep -o '[^/n]*$' | cut -d'.' -f-1)
    echo "number of instances in subexp: $num_instances" 
    
    nova_lists="$nxlist/*-nova.list"
    dist_status="$nxlist/dist.status"
    rm $dist_status

    (( total_rec = 0 ))
    (( total_failed = 0 ))

    
    echo "Unique instance id and valid network ip"
    instance_ip=$(cat $nova_lists | grep vm1 | grep = | awk -F'|' '{if ($2!="") {print $2 $7}}' | sort -u)
    echo "$instance_ip" | grep -v '^$' | wc -l
    echo "Unique instance id"
    instances=$(cat $nova_lists | grep vm1 | awk -F'|' '{if ($2!="") {print $2}}' | sort -u)
    echo $instances | grep -v '^$' | wc -l
    sqlin=$(cat $nova_lists | grep vm1 | awk -F'|' '{if ($2!="") {print $2}}' | sort -u | awk  '{printf "%s%s%s,", "\x27",$1,"\x27"}')
    sqlin=${sqlin%%","}
    
    #mysql -uroot "nova" -Bse "select uuid,host from instances where uuid IN ($sqlin)"
    dist_record=$(mysql -uroot "nova" -Bse "select uuid,host from instances where uuid IN ($sqlin)")




    for compute in "${computes[@]}"; do
	echo "$compute"

	ha_uuids=$(echo "$dist_record" | grep "$compute" | awk '{print $1}')
	ha_uuids=$(echo "$ha_uuids" | awk '{printf $1"|"}') 
	ha_uuids=${ha_uuids%%"|"}
	if [ -z "$ha_uuids" ] ;  then
	    ha_uuids="NO UUID PRESENTS"
	fi

	echo "Instances: $ha_uuids"
	ha_uuids_ips=$(cat $nova_lists | grep -E "$ha_uuids" | grep -v m1.tiny | grep = | awk -F'|' -v c=$compute ' {gsub(/[ \t]+$/,"",$7); split($7,ip,"="); print c $2 ip[2]}' | sort -u)
	echo "Instance IP:"
	uuids_ips_num=$(echo "$ha_uuids_ips" | grep -v '^$' | wc -l)
	echo "# $compute $uuids_ips_num" >> $dist_status
	echo "$ha_uuids_ips" >> $dist_status
	
    done
    
    echo "----------------------------------------------------------"
done