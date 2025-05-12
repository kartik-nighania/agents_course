#! /bin/bash

# install: curl -s https://raw.githubusercontent.com/kartik-nighania/agents_course/main/setup.sh | sudo bash

export LAB_PORT=8000
export PORT=9000

sudo apt-get update && sudo apt-get install -y \
    git \
    curl \
    wget \
    python3-pip \
    python3-venv

# Install Docker and Docker Compose if not installed
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh ./get-docker.sh
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo apt-get install docker-compose-plugin
    rm -rf ./get-docker.sh
fi

# get course repo
if [ ! -d "agents_course" ]; then
    git clone https://github.com/kartik-nighania/agents_course.git
fi
cd agents_course
git checkout main
git pull

# create venv and install dependencies
rm -rf venv || true
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

echo "\n\n ----Testing everything is working----\n\n"
docker run hello-world
docker compose version
if [ ! -d "agents_course" ]; then
    echo "agents_course directory not found"
    exit 1
fi
echo "agents_course directory found"
# check if venv is activated
if [ ! -d "venv" ]; then
    echo "venv directory not found"
    exit 1
fi
source venv/bin/activate
echo "venv activated"

# check if ports are open
for port in "$LAB_PORT" "$PORT"; do
    if ! sudo netstat -tulpen | grep -q "$port"; then
        echo "port $port is not open"
        exit 1
    fi
    ip=$(sudo netstat -tulpen | grep "$port" | awk '{print $5}')
    echo "port $port is open with ip: $ip"
done

echo "\n\n ----Launching Jupyter lab----\n\n"
jupyter lab --ip=0.0.0.0 --port=8000 --no-browser --allow-root


# launch lab
echo "\n\n ----Goto: http://$ip:$LAB_PORT ----\n\n"