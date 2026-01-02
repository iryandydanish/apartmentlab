#!/usr/bin/env bash
set -e

PROJECT_NAME="apartmentlab-preprod"
BASE_DIR="/apartmentlab/repos/apartmentlab"

cd "$BASE_DIR"

docker compose \
  -p "$PROJECT_NAME" \
  --env-file stacks/preprod/versions.env \
  -f stacks/preprod/aiostreams/compose.yml \
  -f stacks/preprod/bentopdf/compose.yml \
  down --remove-orphans
