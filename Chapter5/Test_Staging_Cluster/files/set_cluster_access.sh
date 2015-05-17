#!/bin/bash

# Setup Client SSH Tunnels
ssh-add ~/.ssh/google_compute_engine &>/dev/null

# SET
# path to the cluster folder where we store our binary files
export PATH=${HOME}/coreos-tsc-gce/bin:$PATH
# fleet tunnel
export FLEETCTL_TUNNEL=control_ip
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false

echo "list fleet machines:"
fleetctl list-machines

echo "list fleet units:"
fleetctl list-units

/bin/bash
