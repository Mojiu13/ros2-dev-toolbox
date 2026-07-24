#!/usr/bin/env bash
set -Eeuo pipefail

ACTION_NAME=""
SERVICE_NAME=""
GOAL_ID=""
REQUEST_FILE=""
CANCEL_ALL=0

usage() {
  cat <<'EOF'
用法：cancel_robot_task.sh --action ACTION [取消方式]
  --goal-id UUID       取消指定 32 位十六进制 Goal UUID，可含连字符
  --request-file YAML  使用完整 action_msgs/srv/CancelGoal 请求
  --all                请求取消该 Action 的全部 Goal
  --service PATH       覆盖默认 <action>/_action/cancel_goal 服务路径
EOF
}

while (($#)); do
  case "$1" in
    --action) ACTION_NAME="${2:?缺少 Action 名称}"; shift 2 ;;
    --service) SERVICE_NAME="${2:?缺少服务路径}"; shift 2 ;;
    --goal-id) GOAL_ID="${2:?缺少 Goal UUID}"; shift 2 ;;
    --request-file) REQUEST_FILE="${2:?缺少请求文件}"; shift 2 ;;
    --all) CANCEL_ALL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -n "$ACTION_NAME" ]] || { printf '缺少 --action\n' >&2; exit 2; }
mode_count=$((CANCEL_ALL + (${#GOAL_ID} > 0) + (${#REQUEST_FILE} > 0)))
((mode_count == 1)) || { printf '必须且只能选择 --goal-id、--request-file 或 --all 之一\n' >&2; exit 2; }

source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
SERVICE_NAME="${SERVICE_NAME:-${ACTION_NAME%/}/_action/cancel_goal}"

if [[ -n "$REQUEST_FILE" ]]; then
  [[ -f "$REQUEST_FILE" ]] || { printf '请求文件不存在：%s\n' "$REQUEST_FILE" >&2; exit 1; }
  request="$(cat "$REQUEST_FILE")"
elif ((CANCEL_ALL)); then
  request='{goal_info: {goal_id: {uuid: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, stamp: {sec: 0, nanosec: 0}}}'
else
  normalized="${GOAL_ID//-/}"
  [[ "$normalized" =~ ^[0-9A-Fa-f]{32}$ ]] || { printf 'Goal UUID 必须是 32 位十六进制字符串\n' >&2; exit 2; }
  uuid_values="$(python3 - "$normalized" <<'PY'
import sys
value = sys.argv[1]
print(', '.join(str(int(value[i:i+2], 16)) for i in range(0, 32, 2)))
PY
)"
  request="{goal_info: {goal_id: {uuid: [${uuid_values}]}, stamp: {sec: 0, nanosec: 0}}}"
fi

printf 'Cancel service: %s\n' "$SERVICE_NAME"
exec ros2 service call "$SERVICE_NAME" action_msgs/srv/CancelGoal "$request"
