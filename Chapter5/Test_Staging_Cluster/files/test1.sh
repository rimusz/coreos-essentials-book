#!/bin/bash

gcloud compute --project="_PROJECT_" ssh  --zone="_ZONE_" "core@tsc-test1" --ssh-flag="-A"
