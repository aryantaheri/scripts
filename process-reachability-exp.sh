#!/bin/bash

if [ ! -z "$1" ] ;  then
    reports=$1
    echo 'Reports dir is: ' $reports
else 
    echo "Usage: $0 REPORT_FOLDER"
    exit 1
fi

nxlists="$reports/*.list"
exp_summary="$reports/exp-summary.stat"
echo "#|instances|networks|total-records|success-records|failed-records|missing-records|average-rt|msg|" > $exp_summary

#each represent a subexperiment, for a specific number of networks
for nxlist in $nxlists ; do
    echo "nX.list $nxlist"
    num_instances=$(echo $nxlist | grep -o '[^/n]*$' | cut -d'.' -f-1)
    echo "number of instances in subexp: $num_instances" 
    
    outputs="$nxlist/*.out"
    num_networks=$(ls -la $outputs | wc -l)
    echo "number of networks in subexp: $num_networks"

    summary="$nxlist/summary.stat"
    detailed="$nxlist/detailed.stat"
    echo "#|instances|networks|total-records|success-records|failed-records|missing-records|average-rt|msg|" > $summary
    echo "#|network-name|instances|records|success|failed|network-average-rt|" > $detailed
    (( total_rec = 0 ))
    (( total_failed = 0 ))
    (( tr_avg = 0 ))
    (( sum_network_rt_avg = 0 ))
    (( total_rt_avg = 0 ))
    
    msg=""
    total_missing="0"
    # each $report represents a specific network in a subexperiment
    for report in $outputs ; do
	echo "     Report file: $report"
	(( network_rec = $(cat $report | grep -v ^# | wc -l) ))
	echo "     Records in network: $network_rec"
	(( network_failed = $(cat $report | grep -v ^# | grep - | wc -l) ))
	echo "     Failed records in network: $network_failed"
	(( total_rec = total_rec + network_rec ))
	(( total_failed = total_failed + network_failed ))
	network_rt_avg=$(cat $report | grep -v -E '(^#|-)' | awk -F'|' '{sum+=$3} END {printf "%.2f\n",sum/NR}' )
	echo "     Average reachability time in network: $network_rt_avg"
	sum_network_rt_avg=$(bc <<< "scale = 2; $sum_network_rt_avg + $network_rt_avg")
	
	network_uuid=$(echo $report | grep -o '[^/n]*$' | cut -d'-' -f-5)
	echo "|$network_uuid|-|$network_rec|$(expr $network_rec - $network_failed)|$network_failed|$network_rt_avg|" >>  $detailed
    done
    total_rt_avg=$(bc <<< "scale = 2; $sum_network_rt_avg / $num_networks")
    subexp_rt_avg=$(cat $outputs | grep -v -E '(^#|-)' | awk -F'|' '{sum+=$3; sumsq+=($3)^2} END {printf "%.2f,%.2f\n",sum/NR,sqrt((sumsq-sum^2/NR)/NR)}')
    echo "===>"
    echo "Subexp results:"
    echo "Total processed records in subexp: $total_rec"
    echo "Total failed records in subexp: $total_failed"
    echo "Total average reachability time in subexp: $total_rt_avg"
    if (( $(bc <<< $num_instances) != total_rec )); then
	#msg=$msg" missing records"
	total_missing=$(bc <<< "$num_instances - $total_rec")

    fi

    echo "|$num_instances|$num_networks|$total_rec|$(expr $total_rec - $total_failed)|$total_failed|$total_missing|$total_rt_avg|$msg|" >> $summary
    echo "|$num_instances|$num_networks|$total_rec|$(expr $total_rec - $total_failed)|$total_failed|$total_missing|$total_rt_avg|$msg|" >> $exp_summary
    echo "----------------------------------------------------------"
done