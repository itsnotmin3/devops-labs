#!/usr/bin/env bash
# Generates steady traffic against store-api so the dashboards actually move.
# Leave it running in its own terminal during the demo.
#
#   ./load.sh                      # hits localhost:8080 (the app's host port)
#   ./load.sh http://SERVER_IP:8080
#
# Stop it with Ctrl-C.

BASE="${1:-http://localhost:8080}"

echo "generating traffic against $BASE — Ctrl-C to stop"
while true; do
  curl -s -o /dev/null "$BASE/api/products"
  curl -s -o /dev/null "$BASE/api/orders"
  curl -s -o /dev/null "$BASE/api/orders"
  sleep 0.2
done
