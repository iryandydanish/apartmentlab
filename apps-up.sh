#!/usr/bin/env bash
set -e

BASE_DIR="$pwd"

if [ "$BASE_DIR" == "/apartmentlab/prod-repo/apartmentlab" ]; then

  PROJECT_NAME="apartmentlab-prod"

  cd "$BASE_DIR"
  docker compose \
    -p "$PROJECT_NAME" \
    --env-file versions.env \
    -f application/aiostreams/compose.yml \
    -f application/bentopdf/compose.yml \
    up -d

  echo "Applications started in production environment."

elif [ "$BASE_DIR" == "/apartmentlab/preprod-repo/apartmentlab" ]; then

  PROJECT_NAME="apartmentlab-preprod"

  cd "$BASE_DIR"
  docker compose \
    -p "$PROJECT_NAME" \
    --env-file versions.env \
    -f application/aiostreams/compose.yml \
    -f application/bentopdf/compose.yml \
    up -d

  echo "Applications started in production environment."

else

  echo "Error: Unknown BASE_DIR. Please check the configuration."

fi