#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$BASE_DIR" = "/apartmentlab/prod-repo/apartmentlab" ]; then

  ENV=prod
  PROJECT_NAME="apartmentlab-prod"

  cd "$BASE_DIR"
  ENV="$ENV" docker compose \
    -p "$PROJECT_NAME" \
    --env-file versions.env \
    -f application/aiostreams/compose.yml \
    -f application/bentopdf/compose.yml \
    -f application/jellyfin/compose.yml \
    down --remove-orphans

  echo "Applications stopped in prod environment."

elif [ "$BASE_DIR" = "/apartmentlab/preprod-repo/apartmentlab" ]; then

  ENV=preprod
  PROJECT_NAME="apartmentlab-preprod"

  cd "$BASE_DIR"
  ENV="$ENV" docker compose \
    -p "$PROJECT_NAME" \
    --profile preprod \
    --env-file versions.env \
    -f application/aiostreams/compose.yml \
    -f application/bentopdf/compose.yml \
    -f application/jellyfin/compose.yml \
    down --remove-orphans

  echo "Applications stopped in preprod environment."

else
  echo "Error: Unknown BASE_DIR. Please check the configuration."
  exit 1
fi