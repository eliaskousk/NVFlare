#!/bin/bash

set -o xtrace

THIS_DIR=$(dirname "$(readlink -f "$0")")

NAME=${1:?}
ZONE=${2:-europe-west4-a}

gcloud compute ssh --project "phd-project-2024" --zone "${ZONE}" --tunnel-through-iap "${NAME}"
