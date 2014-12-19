#!/bin/bash
K=4

NUM_SW=$(((5*$K**2)/4))
NUM_CORE_SW=$((($K**2)/4))
NUM_AGG_SW=$((($K**2)/2))
NUM_EDGE_SW=$((($K**2)/2))
NUM_HOST=$((($K**3)/4))


echo "NUM_SW=$NUM_SW"
echo "NUM_CORE_SW=$NUM_CORE_SW"
echo "NUM_AGG_SW=$NUM_AGG_SW"
echo "NUM_EDGE_SW=$NUM_EDGE_SW"
echo "NUM_HOST=$NUM_HOST"

# Arrays
CORE=()
AGG=()
EDGE=()

HID=0
SID=0
PID=1

pad=$(printf '%0.1s' "0"{1..60})
DPID_LENGTH=16

# Create Core switches
for (( i=0; i<$NUM_CORE_SW; i++ ))
do
    ((SID++))
    dpid=$(printf '%*.*s%s\n' 0 $(($DPID_LENGTH - ${#SID})) "$pad" "$SID")
    echo "Adding core br$SID with dpid=$dpid"
    #ovs-vsctl add-br br$SID -- set bridge br$SID datapath_type=pica8 other-config=datapath-id=$dpid
    CORE+=("br$SID")

done

# Create K pods
for (( i=0; i<$K; i++ ))
do
    
    if [ "$i" -gt 1 ]; then
	echo "Limiting Pod creation to maintain usable ports"
	break
    fi
    echo
    echo "Pod $i:"

    # Create pod's Aggrs 
    POD_AGG=()
    for (( j=0; j<$(($K/2)); j++ ))
    do
	((SID++))
	AGG_SW="br$SID"
	dpid=$(printf '%*.*s%s\n' 0 $(($DPID_LENGTH - ${#SID})) "$pad" "$SID")
	echo "Pod$i---Agg: br$SID with dpid=$dpid"
	#ovs-vsctl add-br br$SID -- set bridge br$SID datapath_type=pica8 other-config=datapath-id=$dpid
	POD_AGG+=("br$SID")
	AGG+=("br$SID")

	# Connect Aggr to Cores
	for (( l=$((($j*$K/2))); l<$((($j+1)*$K/2)); l++ ))
	do
	    sp=$PID
	    dp=$(($PID+1))
	    echo "Pod$i---Ports $AGG_SW($sp) <-> ${CORE[l]}($dp)"
	    # ovs-vsctl add-port $AGG_SW ge-1/1/$sp vlan_mode=access tag=1 -- set interface ge-1/1/$sp type=pica8
	    # ovs-vsctl add-port ${CORE[l]} ge-1/1/$dp vlan_mode=access tag=1 -- set interface ge-1/1/$dp type=pica8
	    ((PID+=2))
	done
	
    done
    echo "Pod$i---POD_AGG=${POD_AGG[*]}"


    # Create pod's Edges
    for (( j=0; j<$(($K/2)); j++ ))
    do
	((SID++))
	EDGE_SW="br$SID"
	dpid=$(printf '%*.*s%s\n' 0 $(($DPID_LENGTH - ${#SID})) "$pad" "$SID")
        echo "Pod$i---+++Edge br$SID with dpid=$dpid"
        #ovs-vsctl add-br br$SID -- set bridge br$SID datapath_type=pica8 other-config=datapath-id=$dpid
        EDGE+=("br$SID")

	# Connects Edge to Aggrs
	for (( l=0; l<$(($K/2)); l++ ))
	do
            sp=$PID
            dp=$(($PID+1))
            echo "Pod$i---+++Ports $EDGE_SW($sp) <-> ${POD_AGG[l]}($dp)"
            # ovs-vsctl add-port $EDGE_SW ge-1/1/$sp vlan_mode=access tag=1 -- set interface ge-1/1/$sp type=pica8
            # ovs-vsctl add-port ${POD_AGG[l]} ge-1/1/$dp vlan_mode=access tag=1 -- set interface ge-1/1/$dp type=pica8
            ((PID+=2))
	done

    done

    echo
done

echo "CORE=${CORE[*]}"
echo "AGG=${AGG[*]}"
echo "EDGE=${EDGE[*]}"
