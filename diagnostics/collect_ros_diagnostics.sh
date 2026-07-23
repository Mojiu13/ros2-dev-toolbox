#!/usr/bin/env bash
set -Eeuo pipefail
OUTPUT="${LOG_DIR:-$HOME/.local/state/ros2-dev-toolbox/logs}/ros_$(date +%Y%m%d_%H%M%S)"
[[ "${1:-}" == --output ]] && OUTPUT="${2:?}"
mkdir -p "$OUTPUT"
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 doctor --report > "$OUTPUT/doctor.txt" 2>&1 || true
ros2 node list > "$OUTPUT/nodes.txt" 2>&1 || true
ros2 topic list -t > "$OUTPUT/topics.txt" 2>&1 || true
ros2 service list -t > "$OUTPUT/services.txt" 2>&1 || true
ros2 action list -t > "$OUTPUT/actions.txt" 2>&1 || true
env | grep -E '^(ROS|RMW|AMENT|COLCON)_' | sort > "$OUTPUT/ros_environment.txt" || true
echo "$OUTPUT"
