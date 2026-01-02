#!/usr/bin/env bash
set -euo pipefail

echo "Shutting down applications"
./apps-down.sh
echo "Starting applications"
./apps-up.sh
echo "Applications restarted successfully."