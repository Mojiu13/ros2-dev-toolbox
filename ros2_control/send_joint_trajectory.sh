#!/usr/bin/env bash
set -Eeuo pipefail
ACTION=""
GOAL_FILE=""
TYPE="control_msgs/action/FollowJointTrajectory"
while (($#)); do case "$1" in --action) ACTION="${2:?}"; shift 2;; --goal-file) GOAL_FILE="${2:?}"; shift 2;; --type) TYPE="${2:?}"; shift 2;; -h|--help) echo '用法：send_joint_trajectory.sh --action PATH --goal-file YAML [--type ACTION_TYPE]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$ACTION" && -f "$GOAL_FILE" ]] || { echo '缺少 action 或 goal 文件' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
exec ros2 action send_goal "$ACTION" "$TYPE" "$(cat "$GOAL_FILE")" --feedback
