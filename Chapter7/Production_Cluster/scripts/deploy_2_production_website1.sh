#!/bin/bash
# Build docker container for website1
# and release it 

ssh-add ~/.ssh/google_compute_engine &>/dev/null

function pause(){
read -p "$*"
}

# Test/Staging cluster
## Fetch GC settings
# project and zone
project=$(cat ~/coreos-tsc-gce/settings | grep project= | head -1 | cut -f2 -d"=")
zone=$(cat ~/coreos-tsc-gce/settings | grep zone= | head -1 | cut -f2 -d"=")
cbuilder1=$(gcloud compute instances list --project=$project | grep -v grep | grep tsc-registry-cbuilder1 | awk {'print $5'})

# create a folder on docker builder
echo "Entering dbuilder docker container"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  core@$cbuilder1 "/usr/bin/docker exec docker-builder /bin/bash -c 'sudo mkdir -p /data/website1 && sudo chmod -R 777 /data/website1'"

# sync files from staging to docker builder
echo "Deploying code to docker builder server !!!"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$cbuilder1 '/usr/bin/docker exec docker-builder rsync -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" -avzW --delete core@10.200.3.1:/home/core/share/nginx/html/ /data/website1'
# change folder permisions to 755
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  core@$cbuilder1 "/usr/bin/docker exec docker-builder /bin/bash -c 'sudo chmod -R 755 /data/website1'"

echo "Build new docker image and push to registry!!!"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$cbuilder1 "/usr/bin/docker exec docker-builder /bin/bash -c 'cd /data && ./build.sh && ./push.sh'"
##

# Production cluster
## Fetch GC settings
# project and zone
project2=$(cat ~/coreos-prod-gce/settings | grep project= | head -1 | cut -f2 -d"=")

# Get servers IPs
control1=$(gcloud compute instances list --project=$project2 | grep -v grep | grep prod-control1 | awk {'print $5'})
web1=$(gcloud compute instances list --project=$project2 | grep -v grep | grep prod-web1 | awk {'print $5'})
web2=$(gcloud compute instances list --project=$project2 | grep -v grep | grep prod-web2 | awk {'print $5'})

echo "Pull new docker image on web1"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$web1 docker pull 10.200.4.1:5000/website1
echo "Pull new docker image on web2"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$web2 docker pull 10.200.4.1:5000/website1

echo "Restart fleet unit"
# restart fleet unit
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$control1 fleetctl stop website1.service
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$control1 fleetctl start website1.service
#
sleep 5
echo " "
echo "List Production cluster fleet units"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$control1 fleetctl list-units

echo " "
echo "Finished !!!"
pause 'Press [Enter] key to continue...'

