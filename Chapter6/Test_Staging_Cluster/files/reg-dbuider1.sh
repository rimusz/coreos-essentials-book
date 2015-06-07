#!/bin/bash

gcloud compute --project="_PROJECT_" ssh --zone="_ZONE_" "core@tsc-registry-cbuilder1" --ssh-flag="-A"
