#! /bin/bash

# install: curl -s https://raw.githubusercontent.com/kartik-nighania/agents_course/main/setup.sh | sudo bash

export LAB_PORT=8000
export PORT=9000
export DEBIAN_FRONTEND=noninteractive

echo "Installing dependencies"
sudo apt-get update -q > /dev/null && sudo apt-get install -y -q \
    git \
    curl \
    wget \
    python3-pip \
    net-tools \
    python3-venv > /dev/null

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

# change to course directory
if [ "$(basename "$PWD")" = "agents_course" ]; then
    echo "Already in agents_course directory"
elif [ -d "agents_course" ]; then
    echo "Changing to agents_course directory"
    cd agents_course
else
    echo "agents_course directory not found, exiting"
    exit 1
fi
git checkout main
git pull

# create venv and install dependencies
rm -rf venv || true
python3 -m venv venv
source venv/bin/activate
echo "Installing pip dependencies"
pip install --quiet -r requirements.txt

echo "\n\n ----Testing everything is working----\n\n"
docker run hello-world
docker compose version

# check if ports are open
ip=$(sudo netstat -tulpen | grep "$LAB_PORT" | awk '{print $5}')
for port in "$LAB_PORT" "$PORT"; do
    if ! sudo netstat -tulpen | grep -q "$port"; then
        echo "port $port is not open"
        exit 1
    fi
    echo "port $port is open with ip: $ip"
done

echo "\n\n ----Launching Jupyter lab----\n\n"
jupyter lab --ip=0.0.0.0 --port=8000 --no-browser --allow-root


# launch lab
source venv/bin/activate
echo "\n\n ----Goto: http://$ip:$LAB_PORT ----\n\n"