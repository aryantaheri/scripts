#!/bin/bash

if [ ! -z "$1" ] ;  then
    reports=$1
    echo 'Reports dir is: ' $reports
else 
    echo "Usage: $0 REPORT_FOLDER"
    exit 1
fi

nxlists="$reports/*.list"
exp_udp_summary="$reports/exp-iperf-udp-summary.stat"
echo "#|instances|networks|total-records|success-records|failed-records|missing-records|protocol|time,total-avg-bw,total-std-bw,total-avg-jitter,total-std-jitter,total-avg-lost,total-std-lost,total-avg-dg,total-std-dg,total-avg-outoforder,total-std-outoforder|ctrl->vm-avg-bw,ctrl->vm-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|vm->ctrl-avg-bw,vm->ctrl-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|" > $exp_udp_summary

#each represent a subexperiment, for a specific number of networks
for nxlist in $nxlists ; do
    echo "nX.list $nxlist"
    num_instances=$(echo $nxlist | grep -o '[^/n]*$' | cut -d'.' -f-1)
    echo "number of instances in subexp: $num_instances" 
    
    udp_reports="$nxlist/*-udp.std"
    num_networks=$(ls -la $udp_reports | wc -l)
    echo "number of networks in subexp: $num_networks"


    udp_summary="$nxlist/iperf-udp-summary.stat"
    udp_detailed="$nxlist/iperf-udp-detailed.stat"


    echo "#|instances|networks|total-records|success-records|failed-records|missing-records|protocol|time,total-avg-bw,total-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|ctrl->vm-avg-bw,ctrl->vm-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|vm->ctrl-avg-bw,vm->ctrl-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|" > $udp_summary
    echo "#|networkuuid|instances|records|success|failed|protocol|time,total-avg-bw,total-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|time,ctrl->vm-avg-bw,ctrl->vm-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|time,vm->ctrl-avg-bw,vm->ctrl-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|" > $udp_detailed
    (( total_rec = 0 ))
    (( total_failed = 0 ))

    
    msg=""
    total_missing="0"
    # each $report represents a specific network in a subexperiment
    for report in $udp_reports ; do
	echo "     Report file: $report"
	(( network_rec = $(cat $report | grep -v ^# | wc -l) ))
	echo "     Records in network: $network_rec"
	(( network_failed = $(cat $report | grep -v ^# | grep ,-, | wc -l) ))
	echo "     Failed records in network: $network_failed"
	(( total_rec = total_rec + network_rec ))
	(( total_failed = total_failed + network_failed ))


#awk -F',' '{ if(NR%3 ==  2) {bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1} } END {printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}'

	network_cv_record=$(cat $report | grep -v ,-, | awk -F',' '{ if(NR%3 ==  2) {bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1} } END {printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')

	network_vc_record=$(cat $report | grep -v ,-, | awk -F',' '{ if(NR%3 ==  0) {bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1} } END {printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')

	network_total_record=$(cat $report | grep -v ,-, | awk -F',' '{bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1}  END {printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')

	
	network_uuid=$(echo $report | grep -o '[^/n]*$' | cut -d'-' -f-5)
	echo "|$network_uuid|-|$network_rec|$(expr $network_rec - $network_failed)|$network_failed|UDP|$network_total_record|$network_cv_record|$network_vc_record|" >>  $udp_detailed
	echo "     |$network_uuid|-|$network_rec|$(expr $network_rec - $network_failed)|$network_failed|UDP|$network_total_record|$network_cv_record|$network_vc_record|"
    done

    subexp_udp_cv_record=$(cat $udp_reports | grep -v ,-, | awk -F',' '{ if(NR%3 ==  2) {bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1} } END {printf "%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')


    subexp_udp_vc_record=$(cat $udp_reports | grep -v ,-, | awk -F',' '{ if(NR%3 ==  0) {bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1} } END {printf "%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')


    subexp_udp_total_record=$(cat $udp_reports | grep -v ,-, | awk -F',' '{bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1}  END {printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')

    echo "===>"
    echo "Subexp results:"
    echo "Total processed records in subexp: $total_rec"
    echo "Total processed records in subexp: $(cat $udp_reports | grep -v ^# | wc -l)"
    echo "Total failed records in subexp: $total_failed"
    echo "Total failed records in subexp: $(cat $udp_reports | grep -v ^# | grep ,-, | wc -l)"
    echo "Total average reachability time in subexp: $total_rt_avg"
    if (( $(bc <<< $num_instances) != total_rec )); then
	#msg=$msg" missing records"
	total_missing=$(bc <<< "3 * $num_instances - $total_rec")

    fi
    
    echo "|$num_instances|$num_networks|$total_rec|$(expr $total_rec - $total_failed)|$total_failed|$total_missing|UDP|$subexp_udp_total_record|$subexp_udp_cv_record|$subexp_udp_vc_record|"
    echo "|$num_instances|$num_networks|$total_rec|$(expr $total_rec - $total_failed)|$total_failed|$total_missing|UDP|$subexp_udp_total_record|$subexp_udp_cv_record|$subexp_udp_vc_record|" >> $udp_summary
    echo "|$num_instances|$num_networks|$total_rec|$(expr $total_rec - $total_failed)|$total_failed|$total_missing|UDP|$subexp_udp_total_record|$subexp_udp_cv_record|$subexp_udp_vc_record|" >> $exp_udp_summary
    echo "----------------------------------------------------------"
done