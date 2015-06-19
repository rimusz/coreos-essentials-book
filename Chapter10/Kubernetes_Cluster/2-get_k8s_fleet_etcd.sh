#!/bin/bash

ssh-add ~/.ssh/google_compute_engine &>/dev/null

# Install/update etcdctl, fleetctl and kubectl

# fetch from settings file
project=$(cat settings | grep project= | head -1 | cut -f2 -d"=")
master_name=$(cat settings | grep master_name= | head -1 | cut -f2 -d"=")

# get master external IP
master_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep $master_name | awk {'print $5'});
# path to the folder where we store our binary files
export PATH=${HOME}/k8s-cluster/bin:$PATH

function pause(){
read -p "$*"
}

# get latest k8s version
function get_latest_version_number {
local -r latest_url="https://storage.googleapis.com/kubernetes-release/release/latest.txt"
if [[ $(which wget) ]]; then
  wget -qO- ${latest_url}
elif [[ $(which curl) ]]; then
  curl -Ss ${latest_url}
fi
}

k8s_version=$(get_latest_version_number)

# create tmp folder
mkdir tmp

echo "Downloading and instaling fleetctl, etcdctl and kubectl ..."
# First let's check which OS we use: OS X or Linux
uname=$(uname)

if [[ "${uname}" == "Darwin" ]]
then
    # OS X
    #
    cd ./tmp
    # download etcd and fleet clients for OS X
    ETCD_RELEASE=$(ssh core@$master_ip etcdctl --version | cut -d " " -f 3- | tr -d '\r')
    echo "Downloading etcdctl v$ETCD_RELEASE for OS X"
    curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$ETCD_RELEASE/etcd-v$ETCD_RELEASE-darwin-amd64.zip"
    unzip -j -o "etcd.zip" "etcd-v$ETCD_RELEASE-darwin-amd64/etcdctl"
    mv -f etcdctl ~/k8s-cluster/bin
    # clean up
    rm -f etcd.zip
    echo "etcdctl was copied to ~/k8s-cluster/bin"
    echo " "

    #
    FLEET_RELEASE=$(ssh core@$master_ip fleetctl version | cut -d " " -f 3- | tr -d '\r')
    echo "Downloading fleetctl v$FLEET_RELEASE for OS X"
    curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$FLEET_RELEASE/fleet-v$FLEET_RELEASE-darwin-amd64.zip"
    unzip -j -o "fleet.zip" "fleet-v$FLEET_RELEASE-darwin-amd64/fleetctl"
    mv -f fleetctl ~/k8s-cluster/bin
    # clean up
    rm -f fleet.zip
    echo "fleetctl was copied to ~/k8s-cluster/bin "
    echo " "

    # download kubernetes kubectl for OS X
    echo "Downloading kubernetes $k8s_version kubectl for OS X"
    curl -L -o kubectl https://storage.googleapis.com/kubernetes-release/release/$k8s_version/bin/darwin/amd64/kubectl
    mv -f kubectl ~/k8s-cluster/bin
    #
    echo " "
    echo "kubectl was copied to ~/k8s-cluster/bin"
    echo " "
    # Make them executable
    #
    chmod +x ~/k8s-cluster/bin/*
    cd ..
else
    # Linux
    #
    cd ./tmp
    # download etcd and fleet clients for Linux
    ETCD_RELEASE=$(ssh core@$master_ip etcdctl --version | cut -d " " -f 3- | tr -d '\r')
    echo "Downloading etcdctl $ETCD_RELEASE for Linux"
    curl -L -o etcd.tar.gz "https://github.com/coreos/etcd/releases/download/v$ETCD_RELEASE/etcd-v$ETCD_RELEASE-linux-amd64.tar.gz"
    tar -zxvf etcd.tar.gz etcd-v$ETCD_RELEASE-linux-amd64/etcdctl
    mv -f etcd-v$ETCD_RELEASE-linux-amd64/etcdctl ~/k8s-cluster/bin
    # clean up
    rm -f etcd.tar.gz
    rm -rf etcd-v$ETCD_RELEASE-linux-amd64
    echo "etcdctl was copied to ~/k8s-cluster/bin"
    echo " "

    FLEET_RELEASE=$(ssh core@$master_ip fleetctl version | cut -d " " -f 3- | tr -d '\r')
    cd ./tmp
    echo "Downloading fleetctl v$FLEET_RELEASE for Linux"
    curl -L -o fleet.tar.gz "https://github.com/coreos/fleet/releases/download/v$FLEET_RELEASE/fleet-v$FLEET_RELEASE-linux-amd64.tar.gz"
    tar -zxvf fleet.tar.gz fleet-v$FLEET_RELEASE-linux-amd64/fleetctl
    mv -f fleet-v$FLEET_RELEASE-linux-amd64/fleetctl ~/k8s-cluster/bin
    # clean up
    rm -f fleet.tar.gz
    rm -rf fleet-v$FLEET_RELEASE-linux-amd64
    echo "fleetctl was copied to ~/k8s-cluster/bin"

    # download kubernetes kubectl for Linux
    echo "Downloading kubernetes $k8s_version kubectl for Linux"
    curl -L -o kubectl https://storage.googleapis.com/kubernetes-release/release/$k8s_version/bin/linux/amd64/kubectl
    mv -f kubectl ~/k8s-cluster/bin
    echo "kubectl was copied to ~/k8s-cluster/bin"
    echo " "

    #
    # Make them executable
    chmod +x ~/k8s-cluster/bin/*
    #
    cd ..
fi
echo " "
echo "Instaling of fleetctl, etcdctl and kubectl has finished !!!"
pause 'Press [Enter] key to continue ...'
