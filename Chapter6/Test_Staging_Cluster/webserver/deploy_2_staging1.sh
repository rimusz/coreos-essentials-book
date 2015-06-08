#!/bin/bash

function pause(){
read -p "$*"
}

## Fetch GC settings
# project and zone
project=$(cat ~/coreos-tsc-gce/settings | grep project= | head -1 | cut -f2 -d"=")
zone=$(cat ~/coreos-tsc-gce/settings | grep zone= | head -1 | cut -f2 -d"=")

# change folder permissions
gcloud compute --project=$project ssh  --zone=$zone "core@tsc-staging1" --command "sudo chmod -R 755 /home/core/share/"

echo "Deploying code to tsc-staging1 server !!!"
gcloud compute copy-files staging1/index.html tsc-staging1:/home/core/share/nginx/html --zone $zone --project $project

echo " "
echo "Finished !!!"
pause 'Press [Enter] key to continue...'
