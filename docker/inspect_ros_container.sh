#!/usr/bin/env bash
set -Eeuo pipefail
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
FORMAT=""
while (($#)); do case "$1" in
  --container) CONTAINER="${2:?}"; shift 2;; --format) FORMAT="${2:?}"; shift 2;;
  -h|--help) echo '用法：inspect_ros_container.sh [--container NAME] [--format TEMPLATE]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
if [[ -n "$FORMAT" ]]; then docker inspect --format "$FORMAT" "$CONTAINER"; else docker inspect "$CONTAINER"; docker stats --no-stream "$CONTAINER" 2>/dev/null || true; fi
