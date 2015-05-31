#!/bin/bash

function pause(){
read -p "$*"
}

#  coreos-dev-install.sh

# create "coreos-dev-env" and other required folders 
mkdir ~/coreos-dev-env
mkdir ~/coreos-dev-env/vm
mkdir ~/coreos-dev-env/bin
mkdir ~/coreos-dev-env/share
mkdir ~/coreos-dev-env/fleet

# copy scripts
cp -f files/*.sh ~/coreos-dev-env/
# make files executable 
chmod 755 ~/coreos-dev-env/*

# copy vm folder
cp -rf files/vm ~/coreos-dev-env/
#

# copy fleet folder
cp -rf fleet ~/coreos-dev-env/
#

# copy share subfolders/files
cp -rf share ~/coreos-dev-env/
chmod -R 777 ~/coreos-dev-env/share
#

# first up to initialise VM
echo "Setting up CoreOS VM"
cd ~/coreos-dev-env/vm
vagrant box update
vagrant up --provider virtualbox

# Add vagrant ssh key to ssh-agent
vagrant ssh-config core-dev-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add

# download etcd, fleetctl and docker clients
# First let's check which OS we use: OS X or Linux
uname=$(uname)

if [[ "${uname}" == "Darwin" ]]
then
    # OS X
    #
    cd ~/coreos-dev-env/vm
    LATEST_RELEASE=$(vagrant ssh -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
    cd ~/coreos-dev-env/bin
    echo "Downloading etcdctl $LATEST_RELEASE for OS X"
    curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
    unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
    rm -f etcd.zip
    #
    cd ~/coreos-dev-env/vm
    LATEST_RELEASE=$(vagrant ssh -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
    cd ~/coreos-dev-env/bin
    echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
    curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
    unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
    rm -f fleet.zip
    # download docker client
    cd ~/coreos-dev-env/vm
    LATEST_RELEASE=$(vagrant ssh -c 'docker version' | grep 'Server version:' | cut -d " " -f 3- | tr -d '\r')
    echo "Downloading docker v$LATEST_RELEASE client for OS X"
    curl -o ~/coreos-dev-env/bin/docker https://get.docker.com/builds/Darwin/x86_64/docker-$LATEST_RELEASE
    # Make them executable
    chmod +x ~/coreos-dev-env/bin/*
    #
else
    # Linux
    #
    cd ~/coreos-dev-env/vm
    LATEST_RELEASE=$(vagrant ssh -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
    cd ~/coreos-dev-env/bin
    echo "Downloading etcdctl $LATEST_RELEASE for Linux"
    wget "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-linux-amd64.tar.gz"
    tar -zxvf etcd-v$LATEST_RELEASE-linux-amd64.tar.gz etcd-v$LATEST_RELEASE-linux-amd64/etcdctl --strip 1
    rm -f etcd-v$LATEST_RELEASE-linux-amd64.tar.gz
    #
    cd ~/coreos-dev-env/vm
    LATEST_RELEASE=$(vagrant ssh -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
    cd ~/coreos-dev-env/bin
    echo "Downloading fleetctl v$LATEST_RELEASE for Linux"
    wget "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-linux-amd64.tar.gz"
    tar -zxvf fleet-v$LATEST_RELEASE-linux-amd64.tar.gz fleet-v$LATEST_RELEASE-linux-amd64/fleetctl --strip 1
    rm -f fleet-v$LATEST_RELEASE-linux-amd64.tar.gz
    # 
    echo ""
    echo "You need to install docker for Linux if you have not done that yet !!!"
fi
#
cd ~/coreos-dev-env
#
echo "Installation has finished !!!"
echo ""
pause 'Press [Enter] key to continue...'
