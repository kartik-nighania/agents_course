#!/bin/bash
# usage: sudo USE_LOCALHOST=true bash start_lab.sh
export LAB_PORT=${LAB_PORT:-8000}
export TOKEN="agents_course"

export ip=$(curl -s ipinfo.io/ip)
if [ "$USE_LOCALHOST" = "true" ]; then
    export ip="localhost"
fi

pid=$(lsof -t -i:$LAB_PORT)
if [ -n "$pid" ]; then
    echo "Killing process $pid on port $LAB_PORT"
    kill -9 $pid
    sleep 1
fi

rm -rf jupyter.log
touch jupyter.log
chmod 666 jupyter.log

source venv/bin/activate
sudo nohup `which jupyter` lab --ip=0.0.0.0 --port=$LAB_PORT --ContentsManager.allow_hidden=True --allow-root --no-browser -y --NotebookApp.token=$TOKEN > jupyter.log 2>&1 &
echo "Jupyter Lab started with PID: $!"
echo "Go to: http://$ip:$LAB_PORT/lab?token=$TOKEN"