#! /bin/bash

# install: curl -s https://raw.githubusercontent.com/kartik-nighania/agents_course/main/setup.sh | sudo bash

export LAB_PORT=${LAB_PORT:-8000}
export PORT=${PORT:-9000}
export DEBIAN_FRONTEND=noninteractive

PORTS=($LAB_PORT $PORT)
urls=("openai.com" "langchain.com" "docker.com" "pypi.org" "ubuntu.com" "github.com" "ipinfo.io")

echo "Installing dependencies"
sudo apt-get update -q > /dev/null && sudo apt-get install -y -q \
    git \
    curl \
    wget \
    python3-pip \
    net-tools \
    python3-venv > /dev/null

echo "Testing connectivity to all domains..."
for domain in "${urls[@]}"; do
  if ! timeout 10 ping -c 3 -W 3 $domain > /dev/null 2>&1; then
    echo "❌ $domain is NOT accessible"
  fi
done

# Install Docker and Docker Compose if not installed
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh ./get-docker.sh
    sudo groupadd docker
    sudo usermod -aG docker $USER
    systemctl enable docker.service
    systemctl enable containerd.service
    sudo apt-get install docker-compose-plugin
    rm -rf ./get-docker.sh
fi


# install course repo
if [ "$(basename "$PWD")" = "agents_course" ]; then
    echo "Already in agents_course directory"
elif [ -d "agents_course" ]; then
    echo "Changing to agents_course directory"
    cd agents_course
else
    echo "Cloning agents_course repository"
    git clone -q https://github.com/kartik-nighania/agents_course.git 
    cd agents_course
fi
git checkout main
git pull

# create venv and install dependencies
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
echo "Installing pip dependencies"
pip install --quiet -r requirements.txt

echo "----Testing everything is working----"
docker run hello-world
docker compose version

export ip=$(curl -s ipinfo.io/ip)
echo "Found IP: $ip"

test_port() {
    local port=$1

    echo "Checking and killing any existing processes on port $port..."
    local pid=$(lsof -t -i:$port)
    if [ -n "$pid" ]; then
        echo "Killing process $pid on port $port"
        kill -9 $pid
        sleep 1
    else
        echo "No process found on port $port"
    fi

    echo "Starting Python HTTP server on port $port..."
    python3 -m http.server $port &
    server_pid=$!
    sleep 2
    
    # Check if server is working by making an HTTP request
    echo "Checking if server is running on $ip:$port..."
    if curl -s --max-time 7 --head http://$ip:$port > /dev/null; then
        echo "Server is running correctly on $ip:$port"
        result=0
    else
        echo "ERROR: Server failed to start on $ip:$port"
        result=1
    fi

    echo "Final cleanup for $ip:$port..."
    pid=$(lsof -t -i:$port)
    if [ -n "$pid" ]; then
        echo "Killing remaining process $pid on $ip:$port"
        kill -9 $pid
        sleep 1
    fi
    
    return $result
}

# Test ports
for port in "${PORTS[@]}"; do
    if ! test_port $port; then
        echo ""
        echo "Port http://$ip:$port test failed"
    fi
done

chmod +x start_lab.sh
./start_lab.sh
