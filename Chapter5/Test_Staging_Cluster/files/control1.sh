#!/bin/bash

gcloud compute --project="_PROJECT_" ssh --zone="_ZONE_" "core@tsc-control1" --ssh-flag="-A"
