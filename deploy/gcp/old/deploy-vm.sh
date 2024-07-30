#!/bin/bash

set -o xtrace

THIS_DIR=$(dirname "$(readlink -f "$0")")

DRY_RUN=0

ZONE=${1:-europe-west4-a}
IP=${2:?}
CLUSTER_NAME=${3:?}
PARTY_NAME=${4:?}
DEMO_SCRIPT=${5:-run_experiments.sh}
DEMO_ARGS=${6:-'2 cifar10 vgg19 fl'}
MACHINE_TYPE=${7:-n2d-standard-4}
GPU_TYPE=${8:-}
DISK_IMAGE=${9:-nvflare-dev-image-debian-1-us}
DISK_SIZE=${10:-50}
# NO_EXTERNAL_IP=${10:-,no-address}

if [[ ! -z "${GPU_TYPE}" ]]; then
  GPU="--accelerator=count=1,type=${GPU_TYPE}"
  GPU_RENDER_CONFIG_ARG="--gpu"
else
  GPU="--accelerator="
  GPU_RENDER_CONFIG_ARG=""
fi

# Generate cloud-config configuration for Google's Container OS
# cd "${THIS_DIR}/cloud-config/"
# python3 "${THIS_DIR}/cloud-config/render.py" --partyname ${PARTY_NAME} --serverip ${IP::-1} --demoscript ${DEMO_SCRIPT} --demoargs "${DEMO_ARGS}" ${GPU_RENDER_CONFIG_ARG}
# CLOUD_CONFIG="${THIS_DIR}/cloud-config/${PARTY_NAME}.cfg"

# Generate startup script for normal Linux OS
cd "${THIS_DIR}/startup-script/"
python3 "${THIS_DIR}"/startup-script/render.py --partyname ${PARTY_NAME} --serverip ${IP} --serveripcl ${IP::-1} --demoscript ${DEMO_SCRIPT} --demoargs "${DEMO_ARGS}" ${GPU_RENDER_CONFIG_ARG}
STARTUP_SCRIPT="${THIS_DIR}/startup-script/${PARTY_NAME}.sh"

cd "${THIS_DIR}"

if [[ "${DRY_RUN}" == 0 ]]; then
  echo "Deploying GCE VM for $PARTY_NAME" party

  gcloud compute instances create "${CLUSTER_NAME}-${PARTY_NAME}" \
  --project=stromasys-projects \
  --zone="${ZONE}" \
  --machine-type="${MACHINE_TYPE}" ${GPU} \
  --network-interface=network-tier=PREMIUM,private-network-ip="${IP}",subnet=nvflare-network"${NO_EXTERNAL_IP}" \
  --tags=nvflare-node \
  --maintenance-policy=TERMINATE \
  --provisioning-model=STANDARD \
  --service-account=1095933948428-compute@developer.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
  --create-disk=auto-delete=yes,boot=yes,device-name=nvflare-server,image=projects/stromasys-projects/global/images/"${DISK_IMAGE}",mode=rw,size="${DISK_SIZE}",type=projects/stromasys-projects/zones/europe-west4-a/diskTypes/pd-ssd \
  --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring \
  --reservation-affinity=any \
  --metadata=enable-oslogin=true \
  --metadata-from-file startup-script="${STARTUP_SCRIPT}"

  #--metadata-from-file user-data=myconfig.cfg,startup-script=myscript.sh
  #--accelerator=count=1,type="${GPU_TYPE}" \
  #--provisioning-model=SPOT \
  #--network-interface=network-tier=PREMIUM,nic-type=GVNIC,private-network-ip="${IP}",subnet=default"${NO_EXTERNAL_IP}" \
  #--image=projects/ml-images/global/images/c0-deeplearning-common-cu110-v20221107-debian-10
  #--image=projects/ml-images/global/images/c2-deeplearning-pytorch-1-12-cu113-v20221107-debian-10
  #--image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20221101a
  #--image=projects/stromasys-projects/global/images/nvflare-dev-image
fi
