#!/usr/bin/env bash
set -e

PROJECT_NAME="apartmentlab-prod"
BASE_DIR="/apartmentlab/prod-repo/apartmentlab"

cd "$BASE_DIR"

docker compose \
  -p "$PROJECT_NAME" \
  --env-file versions.env \
  -f application/aiostreams/compose.yml \
  -f application/bentopdf/compose.yml \
  down --remove-orphans

