#!/bin/bash
# Create TS cluster control

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
# control instance type
control_machine_type=$(cat settings | grep control_machine_type= | head -1 | cut -f2 -d"=")
# get the latest full image name
image=$(gcloud compute images list | grep -v grep | grep coreos-$channel | awk {'print $1'})
##

# create an instance
gcloud compute instances create tsc-control1 --project=$project --image=$image --image-project=coreos-cloud --boot-disk-size=10 --zone=$zone --machine-type=$control_machine_type --metadata-from-file user-data=cloud-config/control1.yaml --can-ip-forward --tags tsc-control1 tsc

# create a static IP for the new instance
gcloud compute routes create ip-10-200-1-1-tsc-control1 --project=$project \
         --next-hop-instance tsc-control1 \
                  --next-hop-instance-zone $zone \
                           --destination-range 10.200.1.1/32

echo " "
echo "Setup has finished !!!"
pause 'Press [Enter] key to continue...'
