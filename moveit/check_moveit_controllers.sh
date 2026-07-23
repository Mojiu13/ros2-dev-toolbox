#!/usr/bin/env bash
set -Eeuo pipefail
NODE="${MOVE_GROUP_NODE:-/move_group}"
CONFIG=""
while (($#)); do case "$1" in --node) NODE="${2:?}"; shift 2;; --config) CONFIG="${2:?}"; shift 2;; -h|--help) echo '用法：check_moveit_controllers.sh [--node /move_group] [--config controllers.yaml]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 param get "$NODE" moveit_controller_manager 2>/dev/null || true
ros2 action list -t | grep 'FollowJointTrajectory' || true
[[ -f "$CONFIG" ]] && { echo '== config =='; sed -n '1,240p' "$CONFIG"; }
