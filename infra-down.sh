#!/usr/bin/env bash
set -e

PROJECT_NAME="apartmentlab-prod-infra"
BASE_DIR="/apartmentlab/prod-repo/apartmentlab"

cd "$BASE_DIR"

# Cloudflared & Portainer
docker compose \
  -p $PROJECT_NAME \
  --env-file versions.env \
  -f infrastructure/cloudflared/compose.yml \
  -f infrastructure/portainer/compose.yml \
  down --remove-orphans