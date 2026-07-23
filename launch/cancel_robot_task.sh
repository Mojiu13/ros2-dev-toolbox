#!/usr/bin/env bash
set -Eeuo pipefail
ACTION_NAME=""
GOAL_ID=""
while (($#)); do case "$1" in --action) ACTION_NAME="${2:?}"; shift 2;; --goal-id) GOAL_ID="${2:?}"; shift 2;; -h|--help) echo '用法：cancel_robot_task.sh --action ACTION_NAME [--goal-id UUID]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$ACTION_NAME" ]] || { echo '缺少 --action' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
if [[ -n "$GOAL_ID" ]]; then
  ros2 action cancel "$ACTION_NAME" "$GOAL_ID"
else
  echo 'ROS2 CLI 对通用 action 取消能力依版本而异。当前先显示 action 信息；请传入具体 goal ID 或使用任务客户端取消。'
  ros2 action info "$ACTION_NAME"
fi
