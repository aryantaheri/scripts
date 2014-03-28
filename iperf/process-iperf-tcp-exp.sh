#!/bin/bash

if [ ! -z "$1" ] ;  then
    reports=$1
    echo 'Reports dir is: ' $reports
else 
    echo "Usage: $0 REPORT_FOLDER"
    exit 1
fi

nxlists="$reports/*.list"
exp_tcp_summary="$reports/exp-iperf-tcp-summary.stat"
echo "#|instances|networks|total-records|success-records|failed-records|missing-records|protocol|time,total-avg-bw,total-std-bw|ctrl->vm-avg-bw,ctrl->vm-std-bw|vm->ctrl-avg-bw,vm->ctrl-std-bw|" > $exp_tcp_summary

#each represent a subexperiment, for a specific number of networks
for nxlist in $nxlists ; do
    echo "nX.list $nxlist"
    num_instances=$(echo $nxlist | grep -o '[^/n]*$' | cut -d'.' -f-1)
    echo "number of instances in subexp: $num_instances" 
    
    tcp_reports="$nxlist/*-tcp.std"
    num_networks=$(ls -la $tcp_reports | wc -l)
    echo "number of networks in subexp: $num_networks"


    tcp_summary="$nxlist/iperf-tcp-summary.stat"
    tcp_detailed="$nxlist/iperf-tcp-detailed.stat"


    echo "#|instances|networks|total-records|success-records|failed-records|missing-records|protocol|time,total-avg-bw,total-std-bw|ctrl->vm-avg-bw,ctrl->vm-std-bw|vm->ctrl-avg-bw,vm->ctrl-std-bw|" > $tcp_summary
    echo "#|networkuuid|instances|records|success|failed|protocol|time,total-avg-bw,total-std-bw|time,ctrl->vm-avg-bw,ctrl->vm-std-bw|time,vm->ctrl-avg-bw,vm->ctrl-std-bw|" > $tcp_detailed
    (( total_rec = 0 ))
    (( total_failed = 0 ))

    
    msg=""
    total_missing="0"
    # each $report represents a specific network in a subexperiment
    for report in $tcp_reports ; do
	echo "     Report file: $report"
	(( network_rec = $(cat $report | grep -v ^# | wc -l) ))
	echo "     Records in network: $network_rec"
	(( network_failed = $(cat $report | grep -v ^# | grep ,-, | wc -l) ))
	echo "     Failed records in network: $network_failed"
	(( total_rec = total_rec + network_rec ))
	(( total_failed = total_failed + network_failed ))


#	network_cv_bw_avg=$(awk -F',' '{ if($3=="5001") {bwsum+=$9; bwsumsq+=($9)^2; trafficsum+=$8; trafficsumsq+=($8)^2; total+=1} } END {printf "traffic-avg=%.2f traffic-std=%.2f bandwidth-avg=%.2f bandwidth-std=%.2f\n",trafficsum/total, sqrt((trafficsumsq-trafficsum^2/total)/total), bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total)}' $report)

	network_cv_record=$(cat $report | grep -v ,-, | awk -F',' '{ if($5=="5001") {bwsum+=$9; bwsumsq+=($9)^2; time=$7; total+=1} } END {printf "%s,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total)}')
	network_vc_record=$(cat $report | grep -v ,-, | awk -F',' '{ if($3=="5001") {bwsum+=$9; bwsumsq+=($9)^2; time=$7; total+=1} } END {printf "%s,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total)}')
	network_total_record=$(cat $report | grep -v ,-, | awk -F',' '{ {bwsum+=$9; bwsumsq+=($9)^2; time=$7; total+=1} } END {printf "%s,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total)}')

	
	network_uuid=$(echo $report | grep -o '[^/n]*$' | cut -d'-' -f-5)
	echo "|$network_uuid|-|$network_rec|$(expr $network_rec - $network_failed)|$network_failed|TCP|$network_total_record|$network_cv_record|$network_vc_record|" >>  $tcp_detailed
	echo "     |$network_uuid|-|$network_rec|$(expr $network_rec - $network_failed)|$network_failed|TCP|$network_total_record|$network_cv_record|$network_vc_record|"
    done

    subexp_tcp_cv_record=$(cat $tcp_reports | grep -v ,-, | awk -F',' '{ if($5=="5001") {bwsum+=$9; bwsumsq+=($9)^2; time=$7; total+=1} } END {printf "%.2f,%.2f\n", bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total)}')
    subexp_tcp_vc_record=$(cat $tcp_reports | grep -v ,-, | awk -F',' '{ if($3=="5001") {bwsum+=$9; bwsumsq+=($9)^2; time=$7; total+=1} } END {printf "%.2f,%.2f\n", bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total)}')
    subexp_tcp_total_record=$(cat $tcp_reports | grep -v ,-, | awk -F',' '{ {bwsum+=$9; bwsumsq+=($9)^2; time=$7; total+=1} } END {printf "%s,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total)}')

    echo "===>"
    echo "Subexp results:"
    echo "Total processed records in subexp: $total_rec"
    echo "Total processed records in subexp: $(cat $tcp_reports | grep -v ^# | wc -l)"
    echo "Total failed records in subexp: $total_failed"
    echo "Total failed records in subexp: $(cat $tcp_reports | grep -v ^# | grep ,-, | wc -l)"
    echo "Total average reachability time in subexp: $total_rt_avg"
    if (( $(bc <<< $num_instances) != total_rec )); then
	#msg=$msg" missing records"
	total_missing=$(bc <<< "2 * $num_instances - $total_rec")

    fi
    
    echo "|$num_instances|$num_networks|$total_rec|$(expr $total_rec - $total_failed)|$total_failed|$total_missing|TCP|$subexp_tcp_total_record|$subexp_tcp_cv_record|$subexp_tcp_vc_record|"
    echo "|$num_instances|$num_networks|$total_rec|$(expr $total_rec - $total_failed)|$total_failed|$total_missing|TCP|$subexp_tcp_total_record|$subexp_tcp_cv_record|$subexp_tcp_vc_record|" >> $tcp_summary
    echo "|$num_instances|$num_networks|$total_rec|$(expr $total_rec - $total_failed)|$total_failed|$total_missing|TCP|$subexp_tcp_total_record|$subexp_tcp_cv_record|$subexp_tcp_vc_record|" >> $exp_tcp_summary
    echo "----------------------------------------------------------"
done