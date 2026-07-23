#!/usr/bin/env bash
set -Eeuo pipefail
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
[[ "${1:-}" == --container ]] && { CONTAINER="${2:?}"; shift 2; }
exec docker restart "$@" "$CONTAINER"
