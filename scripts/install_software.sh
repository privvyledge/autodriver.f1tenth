#!/bin/bash

# Usage ./install_software.sh

# Author: Boluwatife Olabiran

# Description: Installs the necessary packages and software needed to run the F1/10 code developed by the RASLAB Autonomous Systems Group at the FAMU-FSU College of Engineering.

# Exit immediately if a command exits with a non-zero status.
set -e

sudo apt-get update && sudo apt-get install openssh-server && echo "Installed SSH."  # ssh
sudo apt update && sudo apt install -y python3-dev python3-pip python3-setuptools python3-venv build-essential git curl nano ccmake  && echo "Installation common dependencies"  # common dependencies
sudo pip3 install -U jetson-stats && echo "Installed jtop"  # jtop

# Install Docker. Comment out this block if installed using the sd card method or if docker is already installed.
# Thanks to Jetsonhacks (https://github.com/jetsonhacks/install-docker and https://jetsonhacks.com/2025/02/24/docker-setup-on-jetpack-6-jetson-orin/)
# ### Begin: Docker installation block
sudo apt update && sudo apt install -y nvidia-container

sudo apt update

# Download the Docker installation script.
wget https://get.docker.com -O docker_install.sh

# Check if the Docker installation script was downloaded successfully and is not empty.
if [ ! -s docker_install.sh ]; then
  echo "ERROR: Docker installation script download failed or file is empty."
  rm -f docker_install.sh  # Clean up any partial download.
  exit 1  # Exit with an error code.
fi

# Make the Docker installation script executable.
chmod +x docker_install.sh

# Install Docker.
sudo ./docker_install.sh

# An issue with the current Docker 28.0.0 requires a different set of kernel modules to be enabled.
# The JetPack 6.2 release of Jetson doesn't support these. So we downgrade
sudo apt-get install -y docker-ce=5:27.5.1-1~ubuntu.22.04~jammy --allow-downgrades
sudo apt-get install -y docker-ce-cli=5:27.5.1-1~ubuntu.22.04~jammy --allow-downgrades
sudo apt-get install -y docker-compose-plugin=2.32.4-1~ubuntu.22.04~jammy --allow-downgrades
sudo apt-get install -y docker-buildx-plugin=0.20.0-1~ubuntu.22.04~jammy --allow-downgrades
sudo apt-get install -y docker-ce-rootless-extras=5:27.5.1-1~ubuntu.22.04~jammy --allow-downgrades


# The we mark them held so they do not get upgraded with apt upgrade
sudo apt-mark hold docker-ce=5:27.5.1-1~ubuntu.22.04~jammy
sudo apt-mark hold docker-ce-cli=5:27.5.1-1~ubuntu.22.04~jammy
sudo apt-mark hold docker-compose-plugin=2.32.4-1~ubuntu.22.04~jammy
sudo apt-mark hold docker-buildx-plugin=0.20.0-1~ubuntu.22.04~jammy
sudo apt-mark hold docker-ce-rootless-extras=5:27.5.1-1~ubuntu.22.04~jammy

rm docker_install.sh

# Enable and start the Docker service.
sudo systemctl --now enable docker

# Configure NVIDIA Container Toolkit.
sudo nvidia-ctk runtime configure --runtime=docker
echo "Installed docker"
# ### End: Docker installation block

# Restart the docker service and add our user to the docker group to use without sudo
sudo systemctl restart docker
sudo usermod -aG docker $USER
newgrp docker
echo "Added user to docker group."

# Add Nvidia to the default runtime
sudo apt install -y jq
sudo jq '. + {"default-runtime": "nvidia"}' /etc/docker/daemon.json | \
  sudo tee /etc/docker/daemon.json.tmp && \
  sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json
echo "Setup Nvidia as default-runtime"

sudo systemctl daemon-reload && sudo systemctl restart docker  # Restart docker

sudo apt update && sudo apt install -y nvidia-jetpack && echo "Installed nvidia-jetpack" # install nvidia jetpack (optional)

sudo nvpmodel -m 2  && echo "Set MAXN super as NVP power mode."

sudo systemctl disable nvzramconfig && echo "Disabled zram."

sudo fallocate -l 16G /ssd/16GB.swap
sudo mkswap /ssd/16GB.swap
sudo swapon /ssd/16GB.swap
echo "Allocated 16GB Swap memory."

sudo systemctl disable nvargus-daemon.service  && echo "Disabled misc services"

sudo systemctl set-default multi-user.target  # Disable desktop GUI. `sudo systemctl set-default graphical.target` to reenable.

echo "Installation complete"
exit 0