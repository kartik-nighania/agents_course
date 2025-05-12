#!/bin/bash

export LAB_PORT=${LAB_PORT:-8000}
export TOKEN="agents_course"
export ip=$(curl ipinfo.io/ip)

rm -rf jupyter.log
touch jupyter.log
chmod 666 jupyter.log

source venv/bin/activate
sudo nohup jupyter lab --ip=0.0.0.0 --port=$LAB_PORT --no-browser -y --NotebookApp.token=$TOKEN > jupyter.log 2>&1 &
echo "Jupyter Lab started with PID: $!"
echo "Go to: http://$ip:$LAB_PORT/lab?token=$TOKEN"