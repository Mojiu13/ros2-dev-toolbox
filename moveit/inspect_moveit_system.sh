#!/usr/bin/env bash
set -Eeuo pipefail
NODE="${MOVE_GROUP_NODE:-/move_group}"
[[ "${1:-}" == --node ]] && NODE="${2:?}"
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 node info "$NODE"
ros2 param list "$NODE"
ros2 action list -t | grep -E 'move_group|FollowJointTrajectory|MoveGroup' || true
