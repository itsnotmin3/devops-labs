#!/usr/bin/env bash
# Scaffold a Linux practice environment.  Run with:  bash setup-lab.sh
set -e

LAB="$HOME/linux-lab"
rm -rf "$LAB"
mkdir -p "$LAB"/{app,configs,logs}
cd "$LAB"

# a fake "secrets" file and a deploy script (loose perms on purpose — you fix them)
printf 'MONGO_URL=mongodb://localhost:27017\nJWT=change-me\n' > secret.env
printf '#!/bin/bash\necho "deploying..."\n' > deploy.sh

# some files to navigate / find / grep
touch app/server.js app/package.json configs/nginx.conf
printf 'INFO  started\nERROR  db connection failed\nINFO  retrying\n' > logs/app.log
printf '127.0.0.1 - "GET / HTTP/1.1" 200\n' > logs/access.log

chmod 644 secret.env deploy.sh    # deliberately world-readable — the lab fixes this

echo "Practice environment ready at: $LAB"
echo "Start with:  cd $LAB && ls -la"
