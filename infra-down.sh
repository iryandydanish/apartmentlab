#!/usr/bin/env bash
set -e

BASE_DIR="/apartmentlab/repos/apartmentlab"
cd "$BASE_DIR"

docker compose \
  -p apartmentlab-infra down \
  -f stacks/prod/cloudflared/compose.yml \
  -f stacks/prod/portainer/compose.yml \
  --remove-orphans

