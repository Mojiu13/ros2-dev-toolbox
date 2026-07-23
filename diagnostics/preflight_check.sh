#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
while (($#)); do case "$1" in --workspace) WORKSPACE="${2:?}"; shift 2;; --container) CONTAINER="${2:?}"; shift 2;; -h|--help) echo '用法：preflight_check.sh [--workspace PATH] [--container NAME]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
failed=0
command -v docker >/dev/null || { echo 'missing: docker'; failed=1; }
[[ -d "$WORKSPACE/src" ]] || { echo "missing: $WORKSPACE/src"; failed=1; }
[[ -f "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash" ]] || { echo 'missing: ROS setup'; failed=1; }
if command -v docker >/dev/null; then docker info >/dev/null 2>&1 || { echo 'unavailable: docker daemon'; failed=1; }; docker container inspect "$CONTAINER" >/dev/null 2>&1 || echo "optional missing: container $CONTAINER"; fi
((failed==0)) && echo 'preflight: passed'
exit "$failed"
