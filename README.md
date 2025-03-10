## Quickstart
1. Purchase materials following the Bill of Materials (BOM) in the `docs` directory.
2. Assemble the car following the assembly instructions in the `docs` directory.
3. Create a ROS2 workspace and navigate to the `src` directory: `mkdir -p ~/f1tenth_ws/src && cd ~/f1tenth_ws/src`
4. Clone this repository: `git clone https://github.com/privvyledge/autodriver.f1tenth.git`
5. Install packages: `cd autodriver.f1tenth && chmod +x scripts/install_software_jetson.sh && ./scripts/install_software_jetson.sh && sudo systemctl restart docker && sudo usermod -aG docker $USER && newgrp docker`
6. Pull the docker image
7. Run teleoperation