#!/usr/bin/env bash
# Launch all demo apps in a tmux session called "nginx-demo".
# Run it with:  bash start-tmux.sh   (using `bash` avoids CRLF shebang issues)
# Attach:       tmux attach -t nginx-demo
# Kill it all:  tmux kill-session -t nginx-demo

cd "$(dirname "$0")" || exit 1

tmux new-session  -d -s nginx-demo -n backend "PORT=3000 NAME=Backend  COLOR=#2563eb node app.js"
tmux new-window   -t nginx-demo    -n web1    "PORT=3001 NAME='Server 1' COLOR=#16a34a node app.js"
tmux new-window   -t nginx-demo    -n web2    "PORT=3002 NAME='Server 2' COLOR=#9333ea node app.js"
tmux new-window   -t nginx-demo    -n web3    "PORT=3003 NAME='Server 3' COLOR=#ea580c node app.js"
tmux new-window   -t nginx-demo    -n api     "PORT=4000 node api.js"

echo "Started tmux session 'nginx-demo'."
echo "Attach:  tmux attach -t nginx-demo      (Ctrl-b then a window number to switch)"
echo "Kill:    tmux kill-session -t nginx-demo"
