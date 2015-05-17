#!/bin/bash

#  vm_up.sh

cd ~/coreos-dev-env/vm

vagrant up

# Add vagrant ssh key to ssh-agent
vagrant ssh-config core-dev-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add &>/dev/null

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://127.0.0.1:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-dev-env/bin:$PATH

# set etcd endpoint
export ETCDCTL_PEERS=http://172.19.20.99:4001
echo " "
echo "etcdctl ls /:"
etcdctl --no-sync ls /
echo " "

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.19.20.99:4001
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "

# list fleet units
echo "fleetctl list-units:"
fleetctl list-units
echo " "

# running docker containers
echo "docker containers:"
docker ps
echo " "
#

cd ~/coreos-dev-env

# open bash shell
/bin/bash
