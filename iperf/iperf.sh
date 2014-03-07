#!/bin/bash -x

ip=$1
ns=$2
tcp_out=$3
udp_out=$4

key="/home/aryan/scripts/iperf/haisen.pem"
user="root"
opt="StrictHostKeyChecking no"

iperf_time="20"
iperf_kill_cmd="killall -9 iperf"

iperf_server_tcp_cmd="nohup iperf -s > iperf.log 2>&1 &"
iperf_client_tcp_cmd="iperf -c $ip  -r -y c -t $iperf_time"

iperf_server_udp_cmd="nohup iperf -s -u > iperf.log 2>&1 &"
iperf_client_udp_cmd="iperf -c $ip  -r -u -y c -t $iperf_time"

ns_prefix="sudo ip netns exec $ns"


# run iperf TCP server
echo "sudo ip netns exec $ns ssh $user@$ip $opt -i $key \"$iperf_server_tcp_cmd\""
$ns_prefix ssh $user@$ip -o "$opt" -i $key "$iperf_server_tcp_cmd"
rc=$?

if [[ $rc -eq 0 ]] ; then
    sleep 2
    echo "$ns_prefix $iperf_client_tcp_cmd"
    $ns_prefix $iperf_client_tcp_cmd

    $ns_prefix ssh $user@$ip -o "$opt" -i $key "$iperf_kill_cmd"
    echo "Done"

else
    echo "Failure"
fi


# run iperf UDP server
echo "sudo ip netns exec $ns ssh $user@$ip $opt -i $key \"$iperf_server_udp_cmd\""
$ns_prefix ssh $user@$ip -o "$opt" -i $key "$iperf_server_udp_cmd"
rc=$?

if [[ $rc -eq 0 ]] ; then
    sleep 2
    echo "$ns_prefix $iperf_client_udp_cmd"
    $ns_prefix $iperf_client_udp_cmd | awk -F',' '{if($10 !=  "") { print $0 }}' 

    $ns_prefix ssh $user@$ip -o "$opt" -i $key "$iperf_kill_cmd"
    echo "Done"

else
    echo "Failure"

fi