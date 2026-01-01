#!/usr/bin/env bash
set -e

BASE_DIR="/apartmentlab/repos/apartmentlab"
cd "$BASE_DIR"

docker compose -p apartmentlab-infra down --remove-orphans
# Intentionally NOT bringing down Portainer by default
