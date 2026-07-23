#!/usr/bin/env bash
set -Eeuo pipefail
MANAGER="${CONTROLLER_MANAGER:-/controller_manager}"
[[ "${1:-}" == --manager ]] && MANAGER="${2:?}"
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 control list_controllers -c "$MANAGER"
ros2 control list_controller_types -c "$MANAGER"
