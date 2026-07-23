#!/usr/bin/env bash
set -Eeuo pipefail
JOINT_STATES="${JOINT_STATES_TOPIC:-/joint_states}"
MOVE_GROUP="${MOVE_GROUP_NODE:-/move_group}"
MANAGER="${CONTROLLER_MANAGER:-/controller_manager}"
while (($#)); do case "$1" in --joint-states) JOINT_STATES="${2:?}"; shift 2;; --move-group) MOVE_GROUP="${2:?}"; shift 2;; --manager) MANAGER="${2:?}"; shift 2;; -h|--help) echo '用法：task_preflight_check.sh [--joint-states TOPIC] [--move-group NODE] [--manager PATH]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 topic echo --once "$JOINT_STATES" >/dev/null
ros2 node info "$MOVE_GROUP" >/dev/null
ros2 control list_controllers -c "$MANAGER" | grep -q active
ros2 action list -t | grep -q FollowJointTrajectory
echo 'task preflight: passed'
