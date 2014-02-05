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
    ns=$2
    echo 'Namespace:' $ns
fi

while [[ $count -ne 0 ]] ; do
    ip netns $ns ping -c 1 $dst                      # Try once.
    rc=$?
    if [[ $rc -eq 0 ]] ; then
        ((count = 1))                      # If okay, flag to exit loop.
    fi
    ((count = count - 1))                  # So we don't go forever.
done

if [[ $rc -eq 0 ]] ; then                  # Make final determination.
    echo 'say The internet is back up.'
else
    echo 'say Timeout.'
fi

end_time=$(($(date +%s%N)/1000000))
echo 'Time to Reachability' `expr $end_time - $start_time` 'milliseconds'

