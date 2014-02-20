#!/bin/bash

nets=$(neutron net-list | grep net | grep -v subnet | awk '{ print $2 }')
image=$(nova image-list | grep cirros | awk '{ print $2 }')
for net in $nets ; do
#     echo "nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1 --num-instances 5"
     for i in {1..7}; do
	 echo "nova boot --flavor m1.tiny --image $image --nic net-id=$net vm$i"
	 nova boot --flavor m1.tiny --image $image --nic net-id=$net vm$i
	 sleep 5
     done
#nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1 --num-instances 10

     sleep 20
     nova list
     nova-manage vm list
     echo "Cleaning all instances"
     ./nova-clean-all.sh
done