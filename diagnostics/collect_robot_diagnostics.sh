#!/usr/bin/env bash
set -Eeuo pipefail
OUTPUT="${LOG_DIR:-$HOME/.local/state/ros2-dev-toolbox/logs}/robot_$(date +%Y%m%d_%H%M%S)"
JOINT_STATES="${JOINT_STATES_TOPIC:-/joint_states}"
MANAGER="${CONTROLLER_MANAGER:-/controller_manager}"
while (($#)); do case "$1" in --output) OUTPUT="${2:?}"; shift 2;; --joint-states) JOINT_STATES="${2:?}"; shift 2;; --manager) MANAGER="${2:?}"; shift 2;; -h|--help) echo '用法：collect_robot_diagnostics.sh [--output DIR] [--joint-states TOPIC] [--manager PATH]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
mkdir -p "$OUTPUT"
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 topic echo --once "$JOINT_STATES" > "$OUTPUT/joint_states.txt" 2>&1 || true
ros2 control list_controllers -c "$MANAGER" > "$OUTPUT/controllers.txt" 2>&1 || true
ros2 control list_hardware_interfaces -c "$MANAGER" > "$OUTPUT/hardware_interfaces.txt" 2>&1 || true
ros2 action list -t > "$OUTPUT/actions.txt" 2>&1 || true
echo "$OUTPUT"
