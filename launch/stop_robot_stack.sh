#!/usr/bin/env bash
set -Eeuo pipefail
PID_FILE="${ROBOT_STACK_PID_FILE:-${XDG_RUNTIME_DIR:-/tmp}/ros2-dev-toolbox-robot-stack.pid}"
SIGNAL=INT
while (($#)); do case "$1" in --pid-file) PID_FILE="${2:?}"; shift 2;; --signal) SIGNAL="${2:?}"; shift 2;; -h|--help) echo '用法：stop_robot_stack.sh [--pid-file FILE] [--signal INT]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -f "$PID_FILE" ]] || { echo "PID 文件不存在：$PID_FILE" >&2; exit 1; }
pid="$(cat "$PID_FILE")"
[[ "$pid" =~ ^[0-9]+$ ]] || { echo 'PID 无效' >&2; exit 1; }
kill -s "$SIGNAL" "$pid"
