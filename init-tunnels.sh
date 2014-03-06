#!/bin/bash

regex="\'(net11|net12|net13|net14|net15|net16|net17|net18|net19|net20)\'"
#nets=$(neutron net-list | grep net | grep -v subnet | grep -E '(net[4-8][1-9]|net[5-8]0)'  | awk '{ print $2 }') 

nets=$(neutron net-list | grep net | grep -v subnet |  awk '{ print $2 }')
echo $nets

image=$(nova image-list | grep cirros | awk '{ print $2 }')
for net in $nets ; do
     echo "nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1 --num-instances 7"
     nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1 --num-instances 7
#     for i in {1..7}; do
#	 echo "nova boot --flavor m1.tiny --image $image --nic net-id=$net vm$i"
#	 nova boot --flavor m1.tiny --image $image --nic net-id=$net vm$i
#	 sleep 5
#     done
#     nova boot --flavor m1.tiny --image $image --nic net-id=$net vm1 --num-instances 10

     sleep 40
     nova list
     nova-manage vm list
     echo "Cleaning all instances"
     ./nova-clean-all.sh
done