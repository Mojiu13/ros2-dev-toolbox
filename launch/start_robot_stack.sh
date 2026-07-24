#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE="${ROBOT_STACK_PACKAGE:-}"
FILE="${ROBOT_STACK_LAUNCH_FILE:-robot_stack.launch.py}"
PID_FILE="${ROBOT_STACK_PID_FILE:-${XDG_RUNTIME_DIR:-/tmp}/ros2-dev-toolbox-robot-stack.pid}"
ARGS=()

while (($#)); do
  case "$1" in
    --package) PACKAGE="${2:?缺少包名}"; shift 2 ;;
    --launch-file) FILE="${2:?缺少 Launch 文件}"; shift 2 ;;
    --pid-file) PID_FILE="${2:?缺少 PID 文件}"; shift 2 ;;
    --) shift; ARGS+=("$@"); break ;;
    -h|--help)
      echo '用法：start_robot_stack.sh --package PKG [--launch-file FILE] [--pid-file FILE] [-- launch 参数]'
      exit 0
      ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -n "$PACKAGE" ]] || { printf '缺少 --package 或 ROBOT_STACK_PACKAGE\n' >&2; exit 2; }
mkdir -p "$(dirname "$PID_FILE")"
printf '%s\n' "$$" >"$PID_FILE"
printf 'PID file: %s\n' "$PID_FILE"
exec bash "${SCRIPT_DIR}/run_ros_launch.sh" --package "$PACKAGE" --launch-file "$FILE" -- "${ARGS[@]}"
