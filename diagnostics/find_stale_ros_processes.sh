#!/usr/bin/env bash
set -Eeuo pipefail
PATTERN="${ROS_PROCESS_PATTERN:-ros2|rviz2|move_group|controller_manager|robot_state_publisher}"
while (($#)); do case "$1" in --pattern) PATTERN="${2:?}"; shift 2;; -h|--help) echo '用法：find_stale_ros_processes.sh [--pattern REGEX]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
pgrep -af "$PATTERN" || true
