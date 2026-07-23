#!/usr/bin/env bash
set -Eeuo pipefail
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
QUERY="${GPU_TEST_COMMAND:-nvidia-smi}"
while (($#)); do case "$1" in
  --container) CONTAINER="${2:?}"; shift 2;; --command) QUERY="${2:?}"; shift 2;;
  -h|--help) echo '用法：test_container_gpu.sh [--container NAME] [--command CMD]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
exec docker exec "$CONTAINER" bash -lc "$QUERY"
