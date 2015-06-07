#!/bin/bash

cp /tmp/authorized_keys /root/.ssh/authorized_keys

chown root:root /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
