#!/usr/bin/env bash
set -e

PROJECT_NAME="apartmentlab-prod"
BASE_DIR="/apartmentlab/prod-repo/apartmentlab"

cd "$BASE_DIR"

# Cloudflared & Portainer
docker compose \
  -p $PROJECT_NAME \
  --env-file versions.env \
  -f application/cloudflared/compose.yml \
  -f application/portainer/compose.yml \
  down --remove-orphans