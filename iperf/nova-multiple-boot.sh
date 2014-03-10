#!/bin/bash

#./nova-boot.sh 5e77a523-6425-4074-ae55-190a52805cb6 e32092b0-1448-44aa-9d80-e593a287c3b4 2  outdir "#|Run Name2|2|1|-|-|false|false|false|partial|gre|"
#./nova-multiple-boot.sh net.list msg
# net.list file format:
# <NET_UUID> <NUM_INSTANCES> <IMAGE_UUID>
# net.list shouldn't have duplicate networks, as it will override the output file

if [ ! -z "$1" ] ;  then
    nets=$1
    echo 'Net list file: ' $nets
fi

if [ ! -z "$2" ] ;  then
    reports=$2
    echo 'Reports dir: ' $reports
fi

if [ ! -z "$3" ] ;  then
    msg=$3
    echo 'Msg: ' $msg
fi

file_name=$(echo $nets | cut -d'/' -f2-)

#fts=$(date +"%y%m%d-%H%M")
outd="$reports/$file_name"
if [ ! -d "$outd/" ] ; then
    mkdir -p $outd
fi

while read -r record; do
    if [ -z "$record" ] ; then
	continue
    fi
    echo "Running nova-boot for ${record}"
    r=($record)
    net=${r[0]}
    num=${r[1]}
    image=${r[2]}
#    log_out="$outd/$net.out"
#    log_err="$outd/$net.err"
    echo "./nova-boot.sh $image $net $num $outd $msg &"
    ./nova-boot.sh  $image $net $num $outd "$msg" &

done < "$nets"