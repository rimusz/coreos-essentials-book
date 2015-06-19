#!/bin/bash

# Create Kubernetes cluster

# Update required settings in "settings" file before running this script

function pause(){
read -p "$*"
}

## Fetch GC settings
# project and zone
project=$(cat settings | grep project= | head -1 | cut -f2 -d"=")
zone=$(cat settings | grep zone= | head -1 | cut -f2 -d"=")
# CoreOS release channel
channel=$(cat settings | grep channel= | head -1 | cut -f2 -d"=")
# master instance type
master_machine_type=$(cat settings | grep master_machine_type= | head -1 | cut -f2 -d"=")
# node instance type
node_machine_type=$(cat settings | grep node_machine_type= | head -1 | cut -f2 -d"=")
# get the latest full image name
image=$(gcloud compute images list --project=$project | grep -v grep | grep coreos-$channel | awk {'print $1'})
#
# master name
master_name=$(cat settings | grep master_name= | head -1 | cut -f2 -d"=")
# node name and count
node_name=$(cat settings | grep node_name= | head -1 | cut -f2 -d"=")
node_count=$(cat settings | grep node_count= | head -1 | cut -f2 -d"=")
##

# create master node
gcloud compute instances create $master_name \
 --project=$project --image=$image --image-project=coreos-cloud \
 --boot-disk-type=pd-standard --boot-disk-size=200 --zone=$zone \
 --machine-type=$master_machine_type --metadata-from-file user-data=./cloud-config/master.yaml \
 --can-ip-forward --scopes compute-rw --tags=k8s-cluster,k8s-master
# create internal static IP for the master
gcloud compute routes create ip-10-222-1-1-$master_name --project=$project \
 --next-hop-instance $master_name \
 --next-hop-instance-zone $zone \
 --destination-range 10.222.1.1/32
#

# create nodes
#  by defaul 2 nodes get created, update node_count in settings file if you want a different number of nodes
for (( i=1; i<=$node_count; i++ ))
do
    gcloud compute instances create $node_name-$i \
     --project=$project --image=$image --image-project=coreos-cloud \
     --boot-disk-type=pd-standard --boot-disk-size=200 --zone=$zone \
     --machine-type=$node_machine_type --metadata-from-file user-data=./cloud-config/node.yaml \
     --can-ip-forward --tags=k8s-cluster,k8s-nodes,prod
done
#

# create a folder to store our binary files and settings file
mkdir -p ~/k8s-cluster/bin
# copy files there
cp -f settings ~/k8s-cluster
cp -f set_k8s_access.sh ~/k8s-cluster/bin
cp -rf units ~/k8s-cluster
echo " "
echo "Cluster machines setup has finished !!!"
pause 'Press [Enter] key to continue ...'
