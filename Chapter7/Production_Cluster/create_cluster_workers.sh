#!/bin/bash
# Create Production cluster workers

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
image=$(gcloud compute images list | grep -v grep | grep coreos-$channel | awk {'print $1'})
##

# create web1 instance
gcloud compute instances create prod-web1 --project=$project --image=$image --image-project=coreos-cloud --boot-disk-size=20 --zone=$zone --machine-type=$worker_machine_type --metadata-from-file user-data=cloud-config/web1.yaml --can-ip-forward --tags prod-web1 prod
# create a static IP for the new instance
gcloud compute routes create ip-10-220-2-1-prod-web1 --project=$project \
         --next-hop-instance prod-web1 \
                  --next-hop-instance-zone $zone \
                           --destination-range 10.220.2.1/32

# create web2 instance
gcloud compute instances create prod-web2 --project=$project --image=$image --image-project=coreos-cloud --boot-disk-size=20 --zone=$zone --machine-type=$worker_machine_type --metadata-from-file user-data=cloud-config/web2.yaml --can-ip-forward --tags prod-web2 prod

# create a static IP for the new instance
gcloud compute routes create ip-10-220-3-1-prod-web2 --project=$project \
         --next-hop-instance prod-web2 \
                  --next-hop-instance-zone $zone \
                           --destination-range 10.220.3.1/32

gcloud compute firewall-rules create http-80 --project=$project --allow tcp:80 --target-tags prod-web1 prod-web2
echo " "
echo "Setup has finished !!!"
pause 'Press [Enter] key to continue...'

