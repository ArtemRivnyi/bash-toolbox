#!/usr/bin/env bash
# docker-cleanup.sh - Lightweight script to remove unused Docker containers, images, volumes, and networks

set -euo pipefail

echo "=========================================="
echo "         Docker Cleanup Utility           "
echo "=========================================="

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker command not found."
    exit 1
fi

echo "[1/4] Removing stopped containers..."
docker container prune -f

echo "[2/4] Removing dangling and unused images..."
docker image prune -a -f --filter "until=72h"

echo "[3/4] Removing unused volumes..."
docker volume prune -f

echo "[4/4] Removing unused networks..."
docker network prune -f

echo "=========================================="
echo "  Cleanup finished successfully!          "
echo "=========================================="
