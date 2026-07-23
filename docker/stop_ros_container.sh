#!/usr/bin/env bash
set -Eeuo pipefail
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
TIMEOUT=10
while (($#)); do case "$1" in
  --container) CONTAINER="${2:?}"; shift 2;; --timeout) TIMEOUT="${2:?}"; shift 2;;
  -h|--help) echo '用法：stop_ros_container.sh [--container NAME] [--timeout 秒]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
exec docker stop --time "$TIMEOUT" "$CONTAINER"
