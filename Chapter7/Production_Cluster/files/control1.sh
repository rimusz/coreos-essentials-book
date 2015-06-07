#!/bin/bash

gcloud compute --project="_PROJECT_" ssh --zone="_ZONE_" "core@prod-control1" --ssh-flag="-A"
