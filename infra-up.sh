#!/usr/bin/env bash
set -e

BASE_DIR="/apartmentlab/repos/apartmentlab"
cd "$BASE_DIR"

# Shared network (idempotent)
docker network inspect edge >/dev/null 2>&1 || docker network create edge

# Cloudflared & Cloudflared (Always On)
docker compose \
  -p apartmentlab-infra \
  --env-file stacks/prod/versions.env \
  -f stacks/prod/cloudflared/compose.yml \
  -f stacks/prod/portainer/compose.yml \
  up -d
