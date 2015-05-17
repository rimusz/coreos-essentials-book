#!/bin/bash

#  vm_up.sh

cd ~/coreos-dev-env/vm

function pause(){
read -p "$*"
}

vagrant halt

pause 'Press [Enter] key to continue...'
