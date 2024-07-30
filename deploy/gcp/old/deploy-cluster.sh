#!/bin/bash

set -o xtrace

THIS_DIR=$(dirname "$(readlink -f "$0")")

NUM_DATA_PARTIES=${1:-1}
ZONE=${2:-europe-west4-a}
SERVER_IP=${3:-10.164.15.1}
CLUSTER_PREFIX=${4:-c10}
CLUSTER_SUFFIX=${5:-default}
CENTER_GPU=${6:-nogpu}
FRONT_GPU=${7:-nogpu}
CENTER_CLIENT_TYPE=${8:-wlc}
DEMO_SCRIPT=${9:-run_experiments.sh}
DEMO_ARGS=${10:-'2 cifar10 vgg19 fl'}

#
# Configure the cluster name
#

CLUSTER_NAME="s${NUM_DATA_PARTIES}"

if [[ ! -z "${CLUSTER_PREFIX}" ]]; then
  CLUSTER_NAME="${CLUSTER_PREFIX}-${CLUSTER_NAME}"
fi

if [[ ! -z "${CLUSTER_SUFFIX}" ]]; then
  CLUSTER_NAME="${CLUSTER_NAME}-${CLUSTER_SUFFIX}"
fi

#
# Configure the cluster machine & gpu
#

if [[ "${CENTER_CLIENT_TYPE}" != "wcl" ]]; then
  SERVER_MACHINE_AND_GPU="n2d-standard-4"
  if [[ "${CENTER_GPU}" == "a100" ]]; then
    CENTER_MACHINE_AND_GPU="a2-highgpu-1g nvidia-tesla-a100"
  elif [[ "${CENTER_GPU}" == "t4" ]]; then
    CENTER_MACHINE_AND_GPU="n1-highmem-4 nvidia-tesla-t4"
  else
    CENTER_MACHINE_AND_GPU="n2d-standard-4"
  fi
else
  if [[ "${CENTER_GPU}" == "a100" ]]; then
    SERVER_MACHINE_AND_GPU="a2-highgpu-1g nvidia-tesla-a100"
  elif [[ "${CENTER_GPU}" == "t4" ]]; then
    SERVER_MACHINE_AND_GPU="n1-highmem-4 nvidia-tesla-t4"
  else
    SERVER_MACHINE_AND_GPU="n2d-standard-4"
  fi
fi

if [[ "${FRONT_GPU}" == "a100" ]]; then
  FRONT_MACHINE_AND_GPU="a2-highgpu-1g nvidia-tesla-a100"
elif [[ "${FRONT_GPU}" == "t4" ]]; then
  FRONT_MACHINE_AND_GPU="n1-highmem-4 nvidia-tesla-t4"
else
  FRONT_MACHINE_AND_GPU="c2d-highmem-8"
fi

#
# Deploy the cluster
#

# Venture Party (with or separate Center Site) + Data Party Sites
./deploy-vm.sh ${ZONE} ${SERVER_IP} ${CLUSTER_NAME} vt ${DEMO_SCRIPT} "${DEMO_ARGS}" ${SERVER_MACHINE_AND_GPU}
if [[ ${CENTER_CLIENT_TYPE} == "wc" ]]; then
  ./deploy-vm.sh ${ZONE} ${SERVER_IP}0 ${CLUSTER_NAME} site-0 ${DEMO_SCRIPT} "${DEMO_ARGS}" ${CENTER_MACHINE_AND_GPU}
fi

first_party=1
last_party=${NUM_DATA_PARTIES}
for id in $(eval echo "{${first_party}..${last_party}}")
do
  ./deploy-vm.sh ${ZONE} ${SERVER_IP}${id} ${CLUSTER_NAME} site-${id} ${DEMO_SCRIPT} "${DEMO_ARGS}" ${FRONT_MACHINE_AND_GPU}
done
