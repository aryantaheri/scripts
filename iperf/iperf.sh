#!/bin/bash -x

ip=$1
ns=$2
output_prefix=$3


tcp_out="$output_prefix-tcp.out"
tcp_err="$output_prefix-tcp.err"

udp_out="$output_prefix-udp.out"
udp_err="$output_prefix-udp.err"

if [ "$ns" == "-" ]; then
    echo "iperf requested for an unreachable ip address $ip. existing"
    echo "-,-,-,$ip,5001,-,-,-,-" >> $tcp_out
    echo "-,-,5001,$ip,-,-,-,-,-" >> $tcp_out

    echo "-,-,-,$ip,5001,-,-,-,-" >> $udp_out
    echo "-,$ip,5001,-,-,-,-,-,-,-,-,-,-,-" >> $udp_out
    echo "-,-,5001,$ip,-,-,-,-,-,-,-,-,-,-" >> $udp_out
    
    exit
fi

key="/home/aryan/scripts/iperf/haisen.pem"
#key="/home/aryan/.ssh/id_rsa"
user="root"
opt="StrictHostKeyChecking no"
opt2="UserKnownHostsFile=/dev/null"

iperf_time="20"
iperf_kill_cmd="killall -9 iperf"

iperf_server_tcp_cmd="nohup iperf -s > iperf.log 2>&1 &"
iperf_client_tcp_cmd="iperf -c $ip  -r -y c -t $iperf_time"

iperf_server_udp_cmd="nohup iperf -s -u > iperf.log 2>&1 &"
iperf_client_udp_cmd="iperf -c $ip  -r -u -y c -t $iperf_time"

ns_prefix="sudo ip netns exec $ns"
#ns_prefix=""

# run iperf TCP server
#echo "sudo ip netns exec $ns ssh $user@$ip $opt -i $key \"$iperf_server_tcp_cmd\""

$ns_prefix ssh $user@$ip -o "$opt" -i $key "$iperf_server_tcp_cmd"
rc=$?

if [[ $rc -eq 0 ]] ; then
    sleep 2
    echo "$ns_prefix $iperf_client_tcp_cmd"
    $ns_prefix $iperf_client_tcp_cmd >> $tcp_out 2>>$tcp_err

    $ns_prefix ssh $user@$ip -o "$opt"  -i $key "$iperf_kill_cmd"
    echo "Done"

else
    echo "-,-,-,$ip,5001,-,-,-,-" >> $tcp_out
    echo "-,-,5001,$ip,-,-,-,-,-" >> $tcp_out
    echo "Failure"
fi


# run iperf UDP server
echo "sudo ip netns exec $ns ssh $user@$ip $opt -o $opt2 -i $key \"$iperf_server_udp_cmd\""
$ns_prefix ssh $user@$ip -o "$opt" -i $key "$iperf_server_udp_cmd"
rc=$?

if [[ $rc -eq 0 ]] ; then
    sleep 2
    echo "$ns_prefix $iperf_client_udp_cmd"
    $ns_prefix $iperf_client_udp_cmd >> $udp_out 2>>$udp_err
    #| awk -F',' '{if($10 !=  "") { print $0 }}'  >> $udp_out

    $ns_prefix ssh $user@$ip -o "$opt"  -i $key "$iperf_kill_cmd"
    echo "Done"

else
    echo "-,-,-,$ip,5001,-,-,-,-" >> $udp_out
    echo "-,$ip,5001,-,-,-,-,-,-,-,-,-,-,-" >> $udp_out
    echo "-,-,5001,$ip,-,-,-,-,-,-,-,-,-,-" >> $udp_out
    echo "Failure"

fi