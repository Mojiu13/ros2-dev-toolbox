#!/usr/bin/env bash
set -Eeuo pipefail
REPORT=0
[[ "${1:-}" == --report ]] && REPORT=1
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
if ((REPORT)); then ros2 doctor --report; else ros2 doctor; fi
ros2 node list
ros2 topic list -t
