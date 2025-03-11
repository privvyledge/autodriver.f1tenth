#!/bin/bash

# Usage ./build_f1tenth_docker.sh

# Author: Boluwatife Olabiran

# Description: Sets up the docker container needed to build and run the F1/10 code.
# This build uses NVIDIA's Isaac container. See https://nvidia-isaac-ros.github.io/getting_started/dev_env_setup.html

# Exit immediately if a command exits with a non-zero status.
set -e

# Install Git LFS
sudo apt-get install git-lfs -y
git lfs install --skip-repo

# Create the ROS2 workspace
mkdir -p ~/f1tenth_ws/src
echo "export ISAAC_ROS_WS=$HOME/f1tenth_ws" >> ~/.bashrc && export ISAAC_ROS_WS=$HOME/f1tenth_ws && echo "export ROS_WS=$HOME/f1tenth_ws" >> ~/.bashrc && echo "export ROS2_WS=$HOME/f1tenth_ws" >> ~/.bashrc && source ~/.bashrc

cd ${ISAAC_ROS_WS}/src
git clone -b release-3.2 https://github.com/privvyledge/isaac_ros_common.git isaac_ros_common
#cd ${ISAAC_ROS_WS}/src/isaac_ros_common/scripts && touch .isaac_ros_common-config && echo CONFIG_IMAGE_KEY=ros2_humble.realsense > .isaac_ros_common-config  # about 1 hour download (with ethernet) + realsense build
#realsense-viewer  # Check if the realsense camera is detected. In docker
cd ${ISAAC_ROS_WS}/src/isaac_ros_common/scripts && touch .isaac_ros_common-config && echo -e "CONFIG_IMAGE_KEY=ros2_humble.realsense.f1tenth\nCONFIG_DOCKER_SEARCH_DIRS=(../../autodriver.f1tenth/docker ../docker)" > .isaac_ros_common-config  # 70 minutes total

# Pull the repositories
cd ${ISAAC_ROS_WS} && vcs import --recursive --workers 1 src < src/autodriver.f1tenth/f1tenth.repos

mkdir -p ${HOME}/shared_dir ${HOME}/data
cd ${ISAAC_ROS_WS}/src/isaac_ros_common/scripts
echo -e "-v /dev:/dev\n-v ${HOME}/shared_dir:/mnt/shared_dir\n-v ${HOME}/data:/mnt/data" > .isaac_ros_dev-dockerargs

# Run the container
cd ${ISAAC_ROS_WS}/src/isaac_ros_common/ && ./scripts/run_dev.sh -d $ISAAC_ROS_WS

## Run the below commands in the container
#cd /workspaces/isaac_ros-dev
#vcs import --recursive --workers 1 src < src/autodriver.f1tenth/f1tenth.repos
