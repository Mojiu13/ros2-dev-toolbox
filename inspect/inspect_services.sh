#!/usr/bin/env bash
set -Eeuo pipefail
SERVICE=""
while (($#)); do case "$1" in --service) SERVICE="${2:?}"; shift 2;; -h|--help) echo '用法：inspect_services.sh [--service /name]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 service list -t
if [[ -n "$SERVICE" ]]; then type="$(ros2 service type "$SERVICE")"; echo "Type: $type"; [[ -n "$type" ]] && ros2 interface show "$type"; fi
