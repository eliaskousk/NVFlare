#cloud-config

users:
- name: nvflare
  uid: 2000

write_files:
  - path: /etc/systemd/system/install-gpu.service
    permissions: 0644
    owner: root
    content: |
      [Unit]
      Description=Install GPU drivers
      Wants=gcr-online.target docker.socket
      After=gcr-online.target docker.socket

      [Service]
      User=root
      Type=oneshot
      ExecStart=cos-extensions install gpu
      ExecStart=mount --bind /var/lib/nvidia /var/lib/nvidia
      ExecStart=mount -o remount,exec /var/lib/nvidia
      StandardOutput=journal+console
      StandardError=journal+console

  - path: /etc/systemd/system/nvflare.service
    permissions: 0644
    owner: root
    content: |
      [Unit]
      Description=Run an NVFlare server application container
      Wants=gcr-online.target
      Requires=install-gpu.service
      After=install-gpu.service

      [Service]
      User=root
      Type=oneshot
      RemainAfterExit=true
      Environment="HOME=/home/nvflare"
      ExecStartPre=/usr/bin/docker-credential-gcr configure-docker
      ExecStartPre=/usr/bin/docker network create --subnet 172.18.0.0/24 nvflare-network
      ExecStart=/usr/bin/docker run --rm -d --name=server --net=nvflare-network --ip 172.18.0.2 -p 8002:8002 -p 8003:8003 --volume /var/lib/nvidia/lib64:/usr/local/nvidia/lib64 --volume /var/lib/nvidia/bin:/usr/local/nvidia/bin --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidia-uvm:/dev/nvidia-uvm --device /dev/nvidiactl:/dev/nvidiactl --shm-size=24G gcr.io/stromasys-projects/nvflare:latest /nvflare/examples/splitnn/workspaces/poc_workspace/server/startup/sub_start.sh 172.18.0.2 172.18.0.2:8002:8003
      ExecStart=/usr/bin/docker run --rm -itd --name=admin --net=nvflare-network gcr.io/stromasys-projects/nvflare:latest /bin/bash -c "sleep 30 && /nvflare/examples/splitnn/workspaces/poc_workspace/admin/startup/fl_admin.sh"
      ExecStart=/usr/bin/docker run --rm -d --name=demo --net=nvflare-network gcr.io/stromasys-projects/nvflare:latest /nvflare/examples/splitnn/{{ demo_script }} server {{ demo_args }}
      ExecStop=/usr/bin/docker stop demo
      ExecStop=/usr/bin/docker stop admin
      ExecStop=/usr/bin/docker stop server
      ExecStopPost=/usr/bin/docker rm demo
      ExecStopPost=/usr/bin/docker rm admin
      ExecStopPost=/usr/bin/docker rm server
      StandardOutput=journal+console
      StandardError=journal+console

runcmd:
  - systemctl daemon-reload
  - systemctl start install-gpu.service
  - systemctl start nvflare.service
