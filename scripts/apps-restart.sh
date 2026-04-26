#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Shutting down applications"
./scripts/apps-down.sh
echo "Starting applications"
./scripts/apps-up.sh
echo "Applications restarted successfully."