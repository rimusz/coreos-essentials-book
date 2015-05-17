#!/bin/bash

# install_fleet_etcd_clients.sh
ssh-add ~/.ssh/google_compute_engine &>/dev/null

function pause(){
read -p "$*"
}

## Fetch GC settings
# project and zone
project=$(cat settings | grep project= | head -1 | cut -f2 -d"=")
zone=$(cat settings | grep zone= | head -1 | cut -f2 -d"=")
# get tsc-control1 server's external IP
control_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep -m 1 tsc-control1 | awk {'print $5'})
# get tsc-test1 server's external IP
test_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep -m 1 tsc-test1 | awk {'print $5'})
# get tsc-staging1 server's external IP
staging_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep -m 1 tsc-staging1 | awk {'print $5'})
##

# create main folder and a few subfolders
mkdir -p ~/coreos-tsc-gce/bin
mkdir -p ~/coreos-tsc-gce/fleet

# copy settings file
cp -f settings ~/coreos-tsc-gce/

echo "Install etcdctl, ssh shell and cluster access scripts"
cp -f files/* ~/coreos-tsc-gce/bin/
cp -f fleet/* ~/coreos-tsc-gce/fleet/

# set control IP
sed -i "" "s/control_ip/$control_ip/"  ~/coreos-tsc-gce/bin/etcdctl
sed -i "" "s/control_ip/$control_ip/"  ~/coreos-tsc-gce/bin/set_cluster_access.sh
# set zone
sed -i "" "s/_ZONE_/$zone/"  ~/coreos-tsc-gce/bin/control1.sh
sed -i "" "s/_ZONE_/$zone/"  ~/coreos-tsc-gce/bin/test1.sh
sed -i "" "s/_ZONE_/$zone/"  ~/coreos-tsc-gce/bin/staging1.sh
# set project
sed -i "" "s/_PROJECT_/$project/"  ~/coreos-tsc-gce/bin/control1.sh
sed -i "" "s/_PROJECT_/$project/"  ~/coreos-tsc-gce/bin/test1.sh
sed -i "" "s/_PROJECT_/$project/"  ~/coreos-tsc-gce/bin/staging1.sh
# make files executables
chmod 755 ~/coreos-tsc-gce/bin/*

# download fleetctl client
# First let's check which OS we use: OS X or Linux
uname=$(uname)

if [[ "${uname}" == "Darwin" ]]
then
    # OS X
    #
    FLEET_RELEASE=$(ssh core@$control_ip fleetctl version | cut -d " " -f 3- | tr -d '\r')
    cd ~/coreos-tsc-gce/bin
    echo "Downloading fleetctl v$FLEET_RELEASE for OS X"
    curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$FLEET_RELEASE/fleet-v$FLEET_RELEASE-darwin-amd64.zip"
    unzip -j -o "fleet.zip" "fleet-v$FLEET_RELEASE-darwin-amd64/fleetctl"
    rm -f fleet.zip
    # Make them executable
    chmod +x ~/coreos-tsc-gce/bin/*
    #
else
    # Linux
    #
    FLEET_RELEASE=$(ssh core@$control_ip fleetctl version | cut -d " " -f 3- | tr -d '\r')
    cd ~/coreos-tsc-gce/bin
    echo "Downloading fleetctl v$FLEET_RELEASE for Linux"
    wget "https://github.com/coreos/fleet/releases/download/v$FLEET_RELEASE/fleet-v$FLEET_RELEASE-linux-amd64.tar.gz"
    tar -zxvf fleet-v$FLEET_RELEASE-linux-amd64.tar.gz fleet-v$FLEET_RELEASE-linux-amd64/fleetctl --strip 1
    rm -f fleet-v$FLEET_RELEASE-linux-amd64.tar.gz
    # Make them executable
    chmod +x ~/coreos-tsc-gce/bin/*
    #
fi
#
cd ~/coreos-tsc-gce

echo " "
echo "Install has finished !!!"
pause 'Press [Enter] key to continue...'
