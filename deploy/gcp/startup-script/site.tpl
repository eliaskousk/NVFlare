#!/usr/bin/env bash

# set -o xtrace

sudo -u elias_kousk_stromasys_com bash -c '<<<_
cd ~/
rm -rf NVFlare
git clone https://eliaskousk:glpat-A-yDa7ppf1Fy-x7cQZ99@gitlab.com/next-gen-data/NVFlare.git
cd NVFlare
git pull
git checkout test-fl

/opt/conda/bin/conda run -n nvflare --no-capture-output pip install rarfile scikit-learn
/opt/conda/bin/conda run -n nvflare --no-capture-output pip install -e .
export SL_DIR=$(readlink -f examples/splitnn)
export PYTHONPATH="${SL_DIR}:${PYTHONPATH}"
echo "PYTHONPATH is ${PYTHONPATH}"
cd examples/splitnn
cd workspaces/poc_workspace

echo "STARTING CLIENT"
/opt/conda/bin/conda run -n nvflare --no-capture-output wandb login a2810e4bfe004024a62aa7ca32fa6f010353ac88
cd {{ name }}/startup
export CUDA_VISIBLE_DEVICES=0  # in case FedOpt uses GPU
tmux new-session -d -s client
tmux send-keys -t client "/opt/conda/bin/conda run -n nvflare --no-capture-output ./start.sh {{ server_ip_client }}:8002:8003 {{ name }}" Enter
<<<_'
