#!/usr/bin/env bash
set -e

PROJECT_NAME="apartmentlab-prod"
BASE_DIR="/apartmentlab/prod-repo/apartmentlab"

cd "$BASE_DIR"

# Shared network (idempotent)
docker network inspect edge >/dev/null 2>&1 || docker network create edge

# Cloudflared & Portainer
docker compose \
  -p $PROJECT_NAME \
  --env-file versions.env \
  -f infrastructure/cloudflared/compose.yml \
  -f infrastructure/portainer/compose.yml \
  up -d
