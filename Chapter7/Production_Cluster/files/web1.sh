#!/bin/bash

gcloud compute --project="_PROJECT_" ssh  --zone="_ZONE_" "core@prod-web1" --ssh-flag="-A"

