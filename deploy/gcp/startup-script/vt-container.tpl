#!/usr/bin/env bash

# set -o xtrace

docker network create --subnet 172.18.0.0/24 nvflare-network
docker pull gcr.io/stromasys-projects/nvflare:latest

docker run --rm -d --name=server --net=nvflare-network --ip 172.18.0.2 -p 8002:8002 -p 8003:8003 --gpus all --shm-size=24G gcr.io/stromasys-projects/nvflare:latest /nvflare/examples/splitnn/workspaces/poc_workspace/server/startup/sub_start.sh 172.18.0.2 172.18.0.2:8002:8003
docker run --rm -d --name=demo --net=nvflare-network gcr.io/stromasys-projects/nvflare:latest /bin/bash -c "cd /nvflare/examples/splitnn && /nvflare/examples/splitnn/{{ demo_script }} server {{ demo_args }}"

docker run --rm -itd --name=admin --net=nvflare-network gcr.io/stromasys-projects/nvflare:latest /bin/bash -c "sleep 30 && /nvflare/examples/splitnn/workspaces/poc_workspace/admin/startup/fl_admin.sh"
