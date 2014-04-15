#!/bin/bash 

if [ ! -z "$1" ] ;  then
    nxlist=$1
    echo 'nxlist dir is: ' $nxlist
else 
    echo "Usage: $0 NXLIST_FOLDER"
    exit 1
fi

#nxlists="$reports/*.list"

#each represent a subexperiment, for a specific number of networks
#for nxlist in $nxlists ; do
    echo "nX.list $nxlist"
    num_instances=$(echo $nxlist | grep -o '[^/n]*$' | cut -d'.' -f-1)
    echo "number of instances in subexp: $num_instances" 
    
    outputs="$nxlist/*.out"
    num_networks=$(ls -la $outputs | wc -l)
    echo "number of networks in subexp: $num_networks"

    # each $report represents a specific network in a subexperiment
    for report in $outputs ; do
	echo "     Report file: $report"

	reachable_ips=$(cat $report | grep -v -E '(^#|-)' | awk -F'|' '{ print $2 }')
	failed_ips=$(cat $report | grep -v '#' | grep - | awk -F'|' '{ print $2 }')
	
	echo "Number of reachable IPs: $(echo $reachable_ips | wc -w)"
	echo "Number of unreachable IPs: $(echo $failed_ips | wc -w)"

	ns="qdhcp-$(echo ${report##*/} | cut -d'-' -f-5)"
	output_prefix="${report%.*}"
	for ip in $reachable_ips ; do
	    ./iperf.sh $ip $ns $output_prefix
	done
	for ip in $failed_ips ; do
	    # log err
	    ./iperf.sh $ip "-" $output_prefix
        done
    done

#done