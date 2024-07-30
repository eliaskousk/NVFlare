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
      Description=Run an NVFlare client application container
      Wants=gcr-online.target
      Requires=install-gpu.service
      After=install-gpu.service

      [Service]
      User=root
      Type=oneshot
      RemainAfterExit=true
      Environment="HOME=/home/nvflare"
      ExecStartPre=/usr/bin/docker-credential-gcr configure-docker
      ExecStartPre=/usr/bin/docker network create nvflare-network
      ExecStart=/usr/bin/docker run --rm -d --name={{ container_name }} --net=nvflare-network --volume /var/lib/nvidia/lib64:/usr/local/nvidia/lib64 --volume /var/lib/nvidia/bin:/usr/local/nvidia/bin --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidia-uvm:/dev/nvidia-uvm --device /dev/nvidiactl:/dev/nvidiactl --shm-size=24G gcr.io/stromasys-projects/nvflare:latest /bin/bash -c "wandb login a2810e4bfe004024a62aa7ca32fa6f010353ac88 && /nvflare/examples/splitnn/workspaces/poc_workspace/{{ name }}/startup/sub_start.sh {{ name }} {{ server_ip }}:8002:8003"
      ExecStop=/usr/bin/docker stop {{ container_name }}
      ExecStopPost=/usr/bin/docker rm {{ container_name }}
      StandardOutput=journal+console
      StandardError=journal+console

runcmd:
  - systemctl daemon-reload
  - systemctl start install-gpu.service
  - systemctl start nvflare.service
