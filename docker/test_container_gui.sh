#!/usr/bin/env bash
set -Eeuo pipefail
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
COMMAND="${GUI_TEST_COMMAND:-xeyes}"
while (($#)); do case "$1" in
  --container) CONTAINER="${2:?}"; shift 2;; --command) COMMAND="${2:?}"; shift 2;;
  -h|--help) echo '用法：test_container_gui.sh [--container NAME] [--command CMD]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
exec docker exec -it -e "DISPLAY=${DISPLAY:-:0}" "$CONTAINER" bash -lc "$COMMAND"
