#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE="${ROBOT_STACK_PACKAGE:-}"
FILE="${ROBOT_STACK_LAUNCH_FILE:-robot_stack.launch.py}"
ARGS=()
while (($#)); do case "$1" in --package) PACKAGE="${2:?}"; shift 2;; --launch-file) FILE="${2:?}"; shift 2;; --) shift; ARGS+=("$@"); break;; -h|--help) echo '用法：start_robot_stack.sh --package PKG [--launch-file FILE] [-- launch 参数]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$PACKAGE" ]] || { echo '缺少 --package 或 ROBOT_STACK_PACKAGE' >&2; exit 2; }
exec "${SCRIPT_DIR}/run_ros_launch.sh" --package "$PACKAGE" --launch-file "$FILE" -- "${ARGS[@]}"
