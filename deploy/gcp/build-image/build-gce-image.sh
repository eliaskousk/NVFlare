#!/bin/bash

gcloud compute images create nvflare-dev-image-latest --project=phd-project-2024 --source-disk=nvflare-dev-1 --source-disk-zone=europe-west4-a --storage-location=eu
