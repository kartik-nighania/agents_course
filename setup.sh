#! /bin/bash

sudo apt-get update && sudo apt-get install -y \
    git \
    curl \
    wget \
    python3-pip \
    python3-venv

# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world

sudo apt-get install docker-compose-plugin
docker compose version


# get course repo
git clone https://github.com/kartik-nighania/agents_course.git
cd agents_course

# create venv and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

