#!/bin/bash

gcloud compute --project="_PROJECT_" ssh  --zone="_ZONE_" "core@prod-web2" --ssh-flag="-A"

