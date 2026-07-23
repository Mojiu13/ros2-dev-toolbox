#!/usr/bin/env bash
set -Eeuo pipefail
ACTION=""
while (($#)); do case "$1" in --action) ACTION="${2:?}"; shift 2;; -h|--help) echo '用法：inspect_actions.sh [--action /name]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 action list -t
[[ -n "$ACTION" ]] && ros2 action info "$ACTION"
