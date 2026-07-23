#!/usr/bin/env bash
set -Eeuo pipefail
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
URL="https://github.com"
TIMEOUT=10
while (($#)); do case "$1" in
  --container) CONTAINER="${2:?}"; shift 2;; --url) URL="${2:?}"; shift 2;; --timeout) TIMEOUT="${2:?}"; shift 2;;
  -h|--help) echo '用法：test_container_network.sh [--container NAME] [--url URL] [--timeout 秒]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
host="$(printf '%s' "$URL" | sed -E 's#^[a-z]+://([^/]+).*#\1#')"
exec docker exec "$CONTAINER" bash -lc "getent hosts '$host' && curl -fsSI --max-time '$TIMEOUT' '$URL' | head"
