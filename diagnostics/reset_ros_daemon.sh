#!/usr/bin/env bash
set -Eeuo pipefail
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 daemon stop || true
sleep "${ROS_DAEMON_RESET_DELAY:-1}"
ros2 daemon start
ros2 node list
