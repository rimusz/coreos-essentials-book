#!/bin/bash

# Install Kubernetes fleet units

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

# update fleet units with k8s version
sed -i "" -e 's/_K8S_VERSION_/'$k8s_version'/g' ./units/*.service
#

# fetch from settings file
project=$(cat settings | grep project= | head -1 | cut -f2 -d"=")
master_name=$(cat settings | grep master_name= | head -1 | cut -f2 -d"=")

# set binaries folder, fleet tunnel to master's external IP
# get master external IP
master_external_ip=$(gcloud compute instances list --project=$project | grep -v grep | grep $master_name | awk {'print $5'});
# path to the folder where we store our binary files
export PATH=${HOME}/k8s-cluster/bin:$PATH
# fleet tunnel
export FLEETCTL_TUNNEL="$master_external_ip"
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false

# deploy fleet units
echo "Kubernetes $k8s_version will be installed ... "
fleetctl start ./units/kube-apiserver.service
fleetctl start ./units/kube-controller-manager.service
fleetctl start ./units/kube-scheduler.service
fleetctl start ./units/kube-register.service
fleetctl start ./units/kube-kubelet.service 
fleetctl start ./units/kube-proxy.service
echo " "
fleetctl list-units

echo " "
echo "Kubernetes Cluster setup has finished !!!"
pause 'Press [Enter] key to continue...'
