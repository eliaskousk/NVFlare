#!/usr/bin/env bash

# set -o xtrace

docker network create nvflare-network
docker pull gcr.io/stromasys-projects/nvflare:latest

docker run --rm -d --name={{ container_name }} --net=nvflare-network --gpus all --shm-size=24G gcr.io/stromasys-projects/nvflare:latest /bin/bash -c "wandb login a2810e4bfe004024a62aa7ca32fa6f010353ac88 && /nvflare/examples/splitnn/workspaces/poc_workspace/{{ name }}/startup/sub_start.sh {{ name }} {{ server_ip_client }}:8002:8003"
