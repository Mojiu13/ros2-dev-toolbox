#!/usr/bin/env bash
set -Eeuo pipefail
TOPIC="${MOVEIT_TRAJECTORY_TOPIC:-/display_planned_path}"
ONCE=0
while (($#)); do case "$1" in --topic) TOPIC="${2:?}"; shift 2;; --once) ONCE=1; shift;; -h|--help) echo '用法：inspect_moveit_trajectory.sh [--topic /display_planned_path] [--once]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
cmd=(ros2 topic echo); ((ONCE)) && cmd+=(--once); exec "${cmd[@]}" "$TOPIC"
