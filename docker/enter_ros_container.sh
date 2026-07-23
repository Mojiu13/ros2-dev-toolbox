#!/usr/bin/env bash
set -Eeuo pipefail
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
WORKDIR="${CONTAINER_WORKSPACE:-/root/ros_ws}"
SHELL_CMD=bash
while (($#)); do case "$1" in
  --container) CONTAINER="${2:?}"; shift 2;; --workdir) WORKDIR="${2:?}"; shift 2;;
  --shell) SHELL_CMD="${2:?}"; shift 2;; -h|--help) echo '用法：enter_ros_container.sh [--container NAME] [--workdir DIR] [--shell CMD]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
exec docker exec -it -w "$WORKDIR" "$CONTAINER" "$SHELL_CMD"
