#!/bin/bash

function pause(){
read -p "$*"
}

## Fetch GC settings
# project and zone
project=$(cat ~/coreos-tsc-gce/settings | grep project= | head -1 | cut -f2 -d"=")
zone=$(cat ~/coreos-tsc-gce/settings | grep zone= | head -1 | cut -f2 -d"=")

echo "Deploy docker image building script to tsc-registry-cbuilder1 server !!!"
gcloud compute copy-files files/* tsc-registry-cbuilder1:/home/core/data --zone $zone --project $project
gcloud compute --project=$project ssh  --zone=$zone "core@tsc-registry-cbuilder1" --command "sudo chmod 755 /home/core/data/*.sh"

echo " "
echo "Finished !!!"
pause 'Press [Enter] key to continue...'
