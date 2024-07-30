#!/usr/bin/env bash

set -x

THIS_DIR=$(dirname "$(readlink -f "$0")")

DRY_RUN=0

STARTUP_SCRIPT="${THIS_DIR}/startup-script/container.sh"

cd "${THIS_DIR}"

if [[ "${DRY_RUN}" == 0 ]]; then

echo "Deploying GCE COS VM"

#
# Machine type: a2-highpu-1g
# GPU type: NVIDIA A100 40GB
# Disk type: balanced
# Cost: $1.23 per hour
#

gcloud compute instances create nemo-a100-40-eu-1 \
--project=phd-project-2024 \
--zone=europe-west4-a \
--tags=nemo-dev \
--machine-type=a2-highgpu-1g \
--accelerator=count=1,type=nvidia-tesla-a100 \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--create-disk=auto-delete=yes,boot=yes,device-name=nemo-a100-40-eu-1,image=projects/ml-images/global/images/c0-deeplearning-common-cu121-v20240128-debian-11-py310,mode=rw,size=100,type=projects/phd-project-2024/zones/europe-west4-a/diskTypes/pd-ssd \
--metadata=enable-oslogin=true \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=goog-ec-src=vm_add-gcloud \
--reservation-affinity=any \
--no-restart-on-failure \
--maintenance-policy=TERMINATE \
--instance-termination-action=STOP \
--provisioning-model=SPOT \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--service-account=829922003828-compute@developer.gserviceaccount.com \
--metadata-from-file startup-script="${STARTUP_SCRIPT}"

fi

# image=projects/cos-cloud/global/images/cos-109-17800-147-15
