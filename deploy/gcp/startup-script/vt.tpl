#!/usr/bin/env bash

# set -o xtrace

sudo -u elias_kousk_stromasys_com bash -c '<<<_
cd ~/
rm -rf NVFlare
git clone https://eliaskousk:glpat-A-yDa7ppf1Fy-x7cQZ99@gitlab.com/next-gen-data/NVFlare.git
cd NVFlare
git pull
git checkout test-fl

/opt/conda/bin/conda run -n nvflare --no-capture-output pip install -e .
SL_DIR=$(readlink -f examples/splitnn)
export PYTHONPATH="${SL_DIR}:${PYTHONPATH}"
echo "PYTHONPATH is ${PYTHONPATH}"
cd examples/splitnn
cd workspaces/poc_workspace

echo "STARTING SERVER"
sed -i -E "s/server:/{{ server_ip }}:/g" admin/startup/fed_admin.json
cd server/startup
export CUDA_VISIBLE_DEVICES=0  # in case FedOpt uses GPU
tmux new-session -d -s server
tmux send-keys -t server "/opt/conda/bin/conda run -n nvflare --no-capture-output ./start.sh {{ server_ip }} {{ server_ip }}:8002:8003" Enter

echo "STARTING DEMO"
cd ../../../../
export DEMO_ARGS=({{ demo_args }})
tmux new-session -d -s demo
tmux send-keys -t demo "/opt/conda/bin/conda run -n nvflare --no-capture-output ./{{ demo_script }} {{ server_ip }} "
for ARG in ${DEMO_ARGS[@]}
do
  tmux send-keys -t demo ${ARG@Q}
  tmux send-keys -t demo " "
done
tmux send-keys -t demo Enter
<<<_'
