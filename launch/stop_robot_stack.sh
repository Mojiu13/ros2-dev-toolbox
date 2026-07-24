#!/usr/bin/env bash
set -Eeuo pipefail

PID_FILE="${ROBOT_STACK_PID_FILE:-${XDG_RUNTIME_DIR:-/tmp}/ros2-dev-toolbox-robot-stack.pid}"
SIGNAL=INT
FORCE=0

while (($#)); do
  case "$1" in
    --pid-file) PID_FILE="${2:?缺少 PID 文件}"; shift 2 ;;
    --signal) SIGNAL="${2:?缺少信号}"; shift 2 ;;
    --force) FORCE=1; shift ;;
    -h|--help)
      echo '用法：stop_robot_stack.sh [--pid-file FILE] [--signal INT] [--force]'
      exit 0
      ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -f "$PID_FILE" ]] || { printf 'PID 文件不存在：%s\n' "$PID_FILE" >&2; exit 1; }
pid="$(cat "$PID_FILE")"
[[ "$pid" =~ ^[0-9]+$ ]] || { printf 'PID 无效\n' >&2; exit 1; }

if ! kill -0 "$pid" 2>/dev/null; then
  printf '进程已经不存在，删除过期 PID 文件：%s\n' "$PID_FILE" >&2
  rm -f -- "$PID_FILE"
  exit 1
fi

command_line="$(ps -p "$pid" -o args=)"
printf 'Target: %s %s\n' "$pid" "$command_line"
if ((!FORCE)) && [[ ! "$command_line" =~ (ros2|launch|move_group|rviz2) ]]; then
  printf 'PID 对应进程不像 ROS2 启动实例；如确认无误请使用 --force。\n' >&2
  exit 1
fi

kill -s "$SIGNAL" "$pid"
rm -f -- "$PID_FILE"
