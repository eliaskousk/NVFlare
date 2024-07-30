DO NOT USE
==========

This readme has old information and must be updated to reflect recent changes in the deployment procedure.

nvflare-vt
==========

docker run --rm -d --name=nvflare-server --net=nvflare-network --ip 172.18.0.2 -p 8002:8002 -p 8003:8003 gcr.io/stromasys-projects/nvflare:splitnn /nvflare/examples/splitnn/workspaces/poc_workspace/server/startup/sub_start.sh 172.18.0.2
docker run --rm -itd --name=nvflare-admin --net=nvflare-network gcr.io/stromasys-projects/nvflare:splitnn /nvflare/examples/splitnn/workspaces/poc_workspace/admin/startup/fl_admin.sh nvflare-server
docker run --rm -d --name=nvflare-center --net=nvflare-network --device /dev/nvidia0:/dev/nvidia0 gcr.io/stromasys-projects/nvflare:splitnn /nvflare/examples/splitnn/workspaces/poc_workspace/site-3/startup/sub_start.sh site-3 nvflare-server


nvflare-site-1
==============

docker run --rm -d --name=nvflare-site-1 --net=nvflare-network --device /dev/nvidia0:/dev/nvidia0 gcr.io/stromasys-projects/nvflare:splitnn /nvflare/examples/splitnn/workspaces/poc_workspace/site-1/startup/sub_start.sh site-1 10.164.15.2

nvflare-site-2
==============

docker run --rm -d --name=nvflare-site-2 --net=nvflare-network --device /dev/nvidia0:/dev/nvidia0 gcr.io/stromasys-projects/nvflare:splitnn /nvflare/examples/splitnn/workspaces/poc_workspace/site-2/startup/sub_start.sh site-2 10.164.15.2
