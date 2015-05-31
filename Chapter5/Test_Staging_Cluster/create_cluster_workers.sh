#!/bin/bash
# Create TS cluster workers

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
# worker instance type
worker_machine_type=$(cat settings | grep worker_machine_type= | head -1 | cut -f2 -d"=")
# get the latest full image name
image=$(gcloud compute images list --project=$project | grep -v grep | grep coreos-$channel | awk {'print $1'})
##

# create test1 instance
gcloud compute instances create tsc-test1 --project=$project --image=$image --image-project=coreos-cloud \
 --boot-disk-size=200 --zone=$zone --machine-type=$worker_machine_type \
 --metadata-from-file user-data=cloud-config/test1.yaml --can-ip-forward --tags=tsc-test1,tsc

# create staging1 instance
gcloud compute instances create tsc-staging1 --project=$project --image=$image --image-project=coreos-cloud \
 --boot-disk-size=200 --zone=$zone --machine-type=$worker_machine_type \
 --metadata-from-file user-data=cloud-config/staging1.yaml --can-ip-forward --tags=tsc-staging1,tsc

# Open port 80 HTTP access to test1 and staging1 instances
gcloud compute firewall-rules create http-80 --project=$project \
 --allow tcp:80 --target-tags=tsc-test1,tsc-staging1

echo " "
echo "Setup has finished !!!"
pause 'Press [Enter] key to continue...'
