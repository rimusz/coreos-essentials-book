#!/bin/bash
# Create TS cluster workers

# Update required settings in "settings" file before running this script

function pause(){
read -p "$*"
}

## Fetch GC settings
# project and zone
project=$(cat ~/coreos-tsc-gce/settings | grep project= | head -1 | cut -f2 -d"=")
zone=$(cat ~/coreos-tsc-gce/settings | grep zone= | head -1 | cut -f2 -d"=")
# CoreOS release channel
channel=$(cat ~/coreos-tsc-gce/settings | grep channel= | head -1 | cut -f2 -d"=")
# worker instance type
worker_machine_type=$(cat ~/coreos-tsc-gce/settings | grep worker_machine_type= | head -1 | cut -f2 -d"=")
# get the latest full image name
image=$(gcloud compute images list | grep -v grep | grep coreos-$channel | awk {'print $1'})
##

# create registry-cbuilder1 instance
gcloud compute instances create tsc-registry-cbuilder1 --project=$project --image=$image --image-project=coreos-cloud --boot-disk-size=40 --zone=$zone --machine-type=$worker_machine_type --metadata-from-file user-data=cloud-config/registry-cbuilder1.yaml --can-ip-forward --tags tsc-registry-cbuilder1 tsc
# create a static IP for the new instance
gcloud compute routes create ip-10-200-4-1-tsc-registry-cbuilder1 --project=$project \
         --next-hop-instance tsc-registry-cbuilder1 \
                  --next-hop-instance-zone $zone \
                           --destination-range 10.200.4.1/32

# copy reg-dbuilder1.sh file
cp files/* ~/coreos-tsc-gce/bin
chmod 755 ~/coreos-tsc-gce/bin/*

# set zone
sed -i "" "s/_ZONE_/$zone/"  ~/coreos-tsc-gce/bin/reg-dbuider1.sh
# set project
sed -i "" "s/_PROJECT_/$project/"  ~/coreos-tsc-gce/bin/reg-dbuider1.sh

# copy fleet units
cp fleet/* ~/coreos-tsc-gce/fleet

# add docker builder container public ssh key
gcloud compute --project=$project ssh  --zone=$zone "core@tsc-staging1" --command 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrJybGYAiSG9Z2ETblpLimDsMoZgkGRyHamecl9X4XVwtgzV6Kl37BgEO2Mhp4D3K48wqn5rRBNETV6UNZPF42epgkEKBFFffZIwLZ9ppJMr0KT21+82jPX059j5OMsz5qLv7UzCocAb/rULk5Rudkh4NXTcXly9ybHWITSJ3hLebZblBPtg5Fi/RG7WnOP+DvLNGJXt89xIvSRHJBrQ4z2zaEKICABLU5Ky6aX4MqJf+9NU15cC7NgFhL+Juhhrm2V66XxN2apikYXEyjMHjaGkJvYPVSjYplydc0WdZb++jjAqGGb0AZQrwT8kcZEk5peHC5LPyaRmTuXqQkFl9J root@tsc-registry-cbuilder1-docker-builder" >> /home/core/.ssh/authorized_keys'

echo " "
echo "Setup has finished !!!"
pause 'Press [Enter] key to continue...'
