#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE="${PICK_PLACE_PACKAGE:-}"
EXECUTABLE="${PICK_PLACE_EXECUTABLE:-}"
ARGS=()
while (($#)); do
  case "$1" in
    --package) PACKAGE="${2:?缺少包名}"; shift 2 ;;
    --executable) EXECUTABLE="${2:?缺少可执行文件}"; shift 2 ;;
    --) shift; ARGS+=("$@"); break ;;
    -h|--help) echo '用法：run_pick_place_task.sh --package PKG --executable EXE [-- ROS 参数]'; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done
[[ -n "$PACKAGE" && -n "$EXECUTABLE" ]] || { printf '缺少任务包或可执行文件\n' >&2; exit 2; }
exec bash "${SCRIPT_DIR}/run_ros_node.sh" --package "$PACKAGE" --executable "$EXECUTABLE" -- "${ARGS[@]}"
