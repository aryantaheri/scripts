#!/bin/bash 


#Time in milliseconds
#$(($(date +%s%N)/1000000))
start_time=$(($(date +%s%N)/1000000))

((count = 100))

if [ ! -z "$1" ] ;  then
    dst=$1
    echo 'Destination is: ' $dst
fi

if [ ! -z "$2" ] ;  then
    ((count = $2))
    echo 'Number of retries:' $count
fi

if [ ! -z "$3" ] ;  then
    ns=$3
    echo 'Namespace:' $ns
fi

if [ ! -z "$4" ] ;  then
    request_time=$4
    echo 'Request Time:' $request_time
fi

if [ ! -z "$5" ] ;  then
    output=$5
    echo 'Output file:' $output
fi

while [[ $count -ne 0 ]] ; do
    sudo ip netns exec $ns ping -c 1 $dst                  
    rc=$?
    if [[ $rc -eq 0 ]] ; then
        ((count = 1))                      
    fi
    ((count = count - 1))                  
done

end_time=$(($(date +%s%N)/1000000))
if [[ $rc -eq 0 ]] ; then
    echo "Dest $dst Time to Reachability" `expr $end_time - $start_time` "milliseconds"
    echo "|$dst|$(expr $end_time - $request_time)|$(expr $end_time - $start_time)|$request_time|$start_time|$end_time|" >> $output
else
    echo "Dest $dst is not reachable"
    echo "|$dst|-|-|$request_time|$start_time|$end_time|" >> $output
fi
