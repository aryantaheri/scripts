#!/bin/bash 

((num = $1))
# ip=a.b.c.d 
((a = $2))
((b = $3))
name=$4
tenant_id=$(keystone tenant-list | grep openstack | awk '{ print $2 }')
for ((i=0;i<$num;i++)); do
    net_num=$(expr $b + $i)
    net_name="$name$net_num"

    subnet_name="sub$name$net_num"
    subnet_cidr="$a.$net_num.0.0/16"
    subnet_gw="$a.$net_num.0.1"
    echo "neutron net-create --tenant-id $tenant_id $net_name"
    neutron net-create --tenant-id $tenant_id $net_name
    echo "neutron subnet-create --tenant-id $tenant_id --gateway $subnet_gw --name $subnet_name $net_name $subnet_cidr"
    neutron subnet-create --tenant-id $tenant_id --gateway $subnet_gw --name $subnet_name $net_name $subnet_cidr
    sleep 2

done