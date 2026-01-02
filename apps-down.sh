#!/usr/bin/env bash
set -e

PROJECT_NAME="apartmentlab-prod"
BASE_DIR="/apartmentlab/repos/apartmentlab"

cd "$BASE_DIR"

docker compose \
  -p "$PROJECT_NAME" \
  --env-file stacks/prod/versions.env \
  -f stacks/prod/aiostreams/compose.yml \
  down --remove-orphans
