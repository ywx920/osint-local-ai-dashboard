#!/usr/bin/env bash
set -euo pipefail

# Rebuild only this project; never rewrite Compose YAML or restart the host daemon.
BASE="${OSINT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
cd "$BASE"
command -v docker >/dev/null || { echo "ERROR: docker is missing" >&2; exit 1; }
command -v sudo >/dev/null || { echo "ERROR: sudo is missing; run Docker Compose directly as an authorized user" >&2; exit 1; }

echo "[1] Validate Compose configuration (including required credentials)"
sudo docker compose config --quiet

echo "[2] Rebuild project images using the checked-in Dockerfiles"
sudo docker compose build --no-cache

echo "[3] Start this project services"
sudo docker compose up -d
sudo docker compose ps
echo "Dashboard: http://${OSINT_BIND_ADDRESS:-127.0.0.1}:7000"
