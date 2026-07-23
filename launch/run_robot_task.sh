#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE="${ROBOT_TASK_PACKAGE:-}"
EXECUTABLE="${ROBOT_TASK_EXECUTABLE:-}"
ARGS=()
while (($#)); do case "$1" in --package) PACKAGE="${2:?}"; shift 2;; --executable) EXECUTABLE="${2:?}"; shift 2;; --) shift; ARGS+=("$@"); break;; -h|--help) echo '用法：run_robot_task.sh --package PKG --executable EXE [-- ROS 参数]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$PACKAGE" && -n "$EXECUTABLE" ]] || { echo '缺少任务包或可执行文件' >&2; exit 2; }
exec "${SCRIPT_DIR}/run_ros_node.sh" --package "$PACKAGE" --executable "$EXECUTABLE" -- "${ARGS[@]}"
