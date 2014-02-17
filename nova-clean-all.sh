#!/bin/bash

uuids=$(nova list | grep -v ID | awk ' $2!="" { print $2 }')
for uuid in $uuids ; do
    echo "Deleting instance $uuid"
    nova delete $uuid
#    sleep 1
done