#!/bin/bash

if [ ! -z "$1" ] ;  then
    reports=$1
    echo 'Reports dir is: ' $reports
else 
    echo "Usage: $0 REPORT_FOLDER"
    exit 1
fi

nxlists="$reports/*.list"
exp_percompute_udp_summary="$reports/exp-percompute-iperf-udp-summary.stat"
echo "#|instances|networks|compute|compute-instances|total-records|success-records|failed-records|missing-records|protocol|time,total-avg-bw,total-std-bw,total-avg-jitter,total-std-jitter,total-avg-lost,total-std-lost,total-avg-dg,total-std-dg,total-avg-outoforder,total-std-outoforder|ctrl->vm-avg-bw,ctrl->vm-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|vm->ctrl-avg-bw,vm->ctrl-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|" > $exp_percompute_udp_summary

declare -a computes=("haisen13" "haisen14" "haisen15" "haisen16" "haisen17")

#each represent a subexperiment, for a specific number of networks
for nxlist in $nxlists ; do
    echo "nX.list $nxlist"
    total_num_instances=$(echo $nxlist | grep -o '[^/n]*$' | cut -d'.' -f-1)
    echo "number of instances in subexp: $total_num_instances" 
    
    udp_reports="$nxlist/*-udp.std"
    num_networks=$(ls -la $udp_reports | grep -v '^$' | wc -l)
    echo "number of networks in subexp: $num_networks"

    dist_status="$nxlist/dist.status"

    percompute_udp_summary="$nxlist/percompute-iperf-udp-summary.stat"
    percompute_udp_detailed="$nxlist/percompute-iperf-udp-detailed.stat"


    echo "#|instances|networks|compute|compute-instances|total-records|success-records|failed-records|missing-records|protocol|time,total-avg-bw,total-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|ctrl->vm-avg-bw,ctrl->vm-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|vm->ctrl-avg-bw,vm->ctrl-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|" > $percompute_udp_summary
    echo "#|networkuuid|instances|compute|compute-instances|records|success|failed|protocol|time,total-avg-bw,total-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|time,ctrl->vm-avg-bw,ctrl->vm-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|time,vm->ctrl-avg-bw,vm->ctrl-std-bw,avg-jitter,std-jitter,avg-lost,std-lost,avg-dg,std-dg,avg-outoforder,std-outoforder|" > $percompute_udp_detailed

    

    # each $report represents a specific network in a subexperiment
    for report in $udp_reports ; do
	echo "     Report file: $report"

        for compute in "${computes[@]}"; do
            compute_ips=$(cat $dist_status | grep $compute | grep -v ^# | awk '{print $3}')
            compute_ips=$(echo "$compute_ips" |  awk '{printf ","$1",|"}')
            compute_ips=${compute_ips%%"|"}   
	    if [ -z "$compute_ips" ] ;  then
		compute_ips="NO IP PRESENTS"
	    fi
	    
	    network_cv_record=$(cat $report | grep -v ,-, | grep -E "$compute_ips" |  awk -F',' '{ if(NR%3 ==  2) {bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1} } END {printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')

	    network_vc_record=$(cat $report | grep -v ,-, | grep -E "$compute_ips" | awk -F',' '{ if(NR%3 ==  0) {bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1} } END {printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')

	    network_total_record=$(cat $report | grep -v ,-, | grep -E "$compute_ips" | awk -F',' '{bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1}  END {printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')

	
	    network_rec=$(cat $report | grep -v ^# | grep -E "$compute_ips" | grep -v '^$' | wc -l)
            network_failed=$(cat $report | grep -v ^# | grep ,-, | grep -E "$compute_ips" | grep -v '^$' | wc -l)

	    network_uuid=$(echo $report | grep -o '[^/n]*$' | cut -d'-' -f-5)
	    echo "|$network_uuid|-|$compute|$network_rec|$(expr $network_rec - $network_failed)|$network_failed|UDP|$network_total_record|$network_cv_record|$network_vc_record|" >>  $percompute_udp_detailed
	    echo "     |$network_uuid|-|$compute|$network_rec|$(expr $network_rec - $network_failed)|$network_failed|UDP|$network_total_record|$network_cv_record|$network_vc_record|"
	done
    done


    (( total_available_instances = 0 ))
    for compute in "${computes[@]}"; do
        compute_ips=$(cat $dist_status | grep $compute | grep -v ^# | awk '{print $3}')
        compute_num_instances=$(echo "$compute_ips" | grep -v '^$' | wc -l)
        compute_ips=$(echo "$compute_ips" |  awk '{printf ","$1",|"}')
        compute_ips=${compute_ips%%"|"}
        if [ -z "$compute_ips" ] ;  then
            compute_ips="NO IP PRESENTS"
        fi

	subexp_udp_cv_record=$(cat $udp_reports | grep -v ,-, | grep -E "$compute_ips" | awk -F',' '{ if(NR%3 ==  2) {bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1} } END {printf "%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')


	subexp_udp_vc_record=$(cat $udp_reports | grep -v ,-, | grep -E "$compute_ips" | awk -F',' '{ if(NR%3 ==  0) {bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1} } END {printf "%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')


	subexp_udp_total_record=$(cat $udp_reports | grep -v ,-, | grep -E "$compute_ips" | awk -F',' '{bwsum+=$9; bwsumsq+=($9)^2; jsum+=$10; jsumsq+=($10)^2; lsum+=$11; lsumsq+=($11)^2; tsum+=$12; tsumsq+=($12)^2; osum+=$14; osumsq+=($14)^2; time=$7; total+=1}  END {printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n", time, bwsum/total, sqrt((bwsumsq-bwsum^2/total)/total), jsum/total, sqrt((jsumsq-jsum^2/total)/total), lsum/total, sqrt((lsumsq-lsum^2/total)/total), tsum/total, sqrt((tsumsq-tsum^2/total)/total), osum/total, sqrt((osumsq-osum^2/total)/total)}')

	compute_rec=$(cat $udp_reports | grep -E "$compute_ips" | grep -v '^$' | wc -l)
        compute_failed=$(cat $udp_reports | grep -E "$compute_ips" | grep ,-, | grep -v '^$' | wc -l)
	
	compute_missing="0"
	if (( $(bc <<< $compute_num_instances) != compute_rec/3 )); then
	    compute_missing=$(bc <<< "3 * $compute_num_instances - $compute_rec")
	fi

	(( total_available_instances = total_available_instances + compute_num_instances ))

	echo "|$total_num_instances|$num_networks|$compute|$compute_num_instances|$compute_rec|$(expr $compute_rec - $compute_failed)|$compute_failed|$compute_missing|UDP|$subexp_udp_total_record|$subexp_udp_cv_record|$subexp_udp_vc_record|"
	echo "|$total_num_instances|$num_networks|$compute|$compute_num_instances|$compute_rec|$(expr $compute_rec - $compute_failed)|$compute_failed|$compute_missing|UDP|$subexp_udp_total_record|$subexp_udp_cv_record|$subexp_udp_vc_record|" >> $percompute_udp_summary
	echo "|$total_num_instances|$num_networks|$compute|$compute_num_instances|$compute_rec|$(expr $compute_rec - $compute_failed)|$compute_failed|$compute_missing|UDP|$subexp_udp_total_record|$subexp_udp_cv_record|$subexp_udp_vc_record|" >> $exp_percompute_udp_summary
	echo "----------------------------------------------------------"
    done
    
    if (( total_available_instances != $(bc <<< $total_num_instances) )); then
	missing_instances=$(bc <<< "$total_num_instances - $total_available_instances ")
        echo "# |$total_num_instances|$num_networks|$missing_instances missing instances" >> $percompute_udp_summary
        echo "# |$total_num_instances|$num_networks|$missing_instances missing instances" >> $exp_percompute_udp_summary
    fi

done