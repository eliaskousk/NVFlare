#!/bin/bash

set -o xtrace

THIS_DIR=$(dirname "$(readlink -f "$0")")

#
# Available regions/zones and subnets for T4 16GB and A100 40GB (in []) GPUs
#
# No  Region        Zone     Subnet  Country/US State
#
# Europe
#
# 1   europe-west1  b,c,d            132     Belgium
# 2   europe-west2  a,b              154     UK
# 3   europe-west3  b                156     Germany
# 4   europe-west4  [a],[b],c        164     Netherlands
#
# US
#
# 5   us-central1   [a],[b],[c],[f]  128     Iowa
# 6   us-east1      c,d              142     South Carolina
# 7   us-east4      a,b,c            150     Virginia
# 8   us-west1      a,[b]            138     Oregon
# 9   us-west2      b,c              168     California
# 10  us-west4      a,[b]            182     Nevada

ZONE=${1:-us-east4-c}
ZONE_SUBNET=${2:-150}

#
# SL - CIFAR-10 Dataset
#

NUM_DATA_PARTIES=2

#ZONE=us-east1-c
#ZONE_SUBNET=142
#./deploy-cluster.sh ${NUM_DATA_PARTIES} "${ZONE}" 10.${ZONE_SUBNET}.15.1 sl-c10-vgg19 bs128 t4 t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} cifar10 vgg19 sl 128 na,10,1,0.1 200:1.0,200:0.5,200:0.25,200:0.0"

#ZONE=us-east4-c
#ZONE_SUBNET=150
#./deploy-cluster.sh ${NUM_DATA_PARTIES} "${ZONE}" 10.${ZONE_SUBNET}.15.2 sl-c10-vgg19 bs256 t4 t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} cifar10 vgg19 sl 256 na,10,1,0.1 200:1.0,200:0.5,200:0.25,200:0.0"

#ZONE=europe-west1-b
#ZONE_SUBNET=132
#./deploy-cluster.sh ${NUM_DATA_PARTIES} "${ZONE}" 10.${ZONE_SUBNET}.15.3 sl-c10-vgg19 bs512 t4 t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} cifar10 vgg19 sl 512 na,10,1,0.1 200:1.0,200:0.5,200:0.25,200:0.0"

#ZONE=europe-west2-b
#ZONE_SUBNET=154
#./deploy-cluster.sh ${NUM_DATA_PARTIES} "${ZONE}" 10.${ZONE_SUBNET}.15.4 sl-c10-vgg19 bs1024 t4 t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} cifar10 vgg19 sl 1024 na,10,1,0.1 200:1.0,200:0.5,200:0.25,200:0.0"

#ZONE=europe-west3-b
#ZONE_SUBNET=156
#./deploy-cluster.sh ${NUM_DATA_PARTIES} "${ZONE}" 10.${ZONE_SUBNET}.15.5 sl-c10-vgg19 bs2048 t4 t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} cifar10 vgg19 sl 2048 na,10,1,0.1 200:1.0,200:0.5,200:0.25,200:0.0"

#ZONE=europe-west4-c
#ZONE_SUBNET=164
#./deploy-cluster.sh ${NUM_DATA_PARTIES} "${ZONE}" 10.${ZONE_SUBNET}.15.6 sl-c10-vgg19 bs4096 t4 t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} cifar10 vgg19 sl 4096 na,10,1,0.1 200:1.0,200:0.5,200:0.25,200:0.0"

# DEBUG S4 BS1024 R3
#NUM_DATA_PARTIES=4
#ZONE=us-east1-c
#ZONE_SUBNET=142
#./deploy-cluster.sh ${NUM_DATA_PARTIES} "${ZONE}" 10.${ZONE_SUBNET}.15.1 sl-c10-vgg19 bs1024-dbg t4 t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} cifar10 vgg19 sl 1024 na,10,1,0.1 3:1.0,3:0.5,3:0.25,3:0.0"


#
# FL & SL - BM Dataset
#

NUM_DATA_PARTIES=2

#ZONE=us-east4-c
#ZONE_SUBNET=150
#./deploy-cluster.sh ${NUM_DATA_PARTIES} ${ZONE} 10.${ZONE_SUBNET}.15.1 fl-bm-smlp bs512 nogpu t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} bm simplemlp fl 512 na,10,1,0.1 200:1,100:2,50:4,20:10 sgd {\"lr\":0.1,\"momentum\":0.9,\"weight_decay\":5e-4}"

#ZONE=europe-west1-b
#ZONE_SUBNET=132
#./deploy-cluster.sh ${NUM_DATA_PARTIES} ${ZONE} 10.${ZONE_SUBNET}.15.1 sl-bm-smlp bs512 t4 t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} bm simplemlp sl 512 na,10,1,0.1 200:1.0,200:0.5,200:0.25,200:0.0 sgd {\"lr\":0.1,\"momentum\":0.9,\"weight_decay\":5e-4}"

NUM_DATA_PARTIES=4

#ZONE=us-east1-c
#ZONE_SUBNET=142
#./deploy-cluster.sh ${NUM_DATA_PARTIES} ${ZONE} 10.${ZONE_SUBNET}.15.1 fl-bm-smlp bs512 nogpu t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} bm simplemlp fl 512 na,10,1,0.1 200:1,100:2,50:4,20:10 sgd {\"lr\":0.1,\"momentum\":0.9,\"weight_decay\":5e-4}"

#ZONE=europe-west2-b
#ZONE_SUBNET=154
#./deploy-cluster.sh ${NUM_DATA_PARTIES} ${ZONE} 10.${ZONE_SUBNET}.15.1 sl-bm-smlp bs512 t4 t4 wcl run_experiments.sh "${NUM_DATA_PARTIES} bm simplemlp sl 512 na,10,1,0.1 200:1.0,200:0.5,200:0.25,200:0.0 sgd {\"lr\":0.1,\"momentum\":0.9,\"weight_decay\":5e-4}"
