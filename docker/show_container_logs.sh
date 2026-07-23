#!/usr/bin/env bash
set -Eeuo pipefail
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
TAIL=200
FOLLOW=0
while (($#)); do case "$1" in
  --container) CONTAINER="${2:?}"; shift 2;; --tail) TAIL="${2:?}"; shift 2;;
  -f|--follow) FOLLOW=1; shift;; -h|--help) echo '用法：show_container_logs.sh [--container NAME] [--tail N] [--follow]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
cmd=(docker logs --tail "$TAIL"); ((FOLLOW)) && cmd+=(--follow); exec "${cmd[@]}" "$CONTAINER"
