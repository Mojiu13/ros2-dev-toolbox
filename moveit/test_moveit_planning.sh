#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
PACKAGE=""
EXECUTABLE=""
ARGS=()
while (($#)); do
  case "$1" in
    --package) PACKAGE="${2:?缺少包名}"; shift 2 ;;
    --executable) EXECUTABLE="${2:?缺少可执行文件}"; shift 2 ;;
    --) shift; ARGS+=("$@"); break ;;
    -h|--help) echo '用法：test_moveit_planning.sh --package PKG --executable EXE [-- ROS 参数]'; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done
[[ -n "$PACKAGE" && -n "$EXECUTABLE" ]] || { printf '缺少 --package 或 --executable\n' >&2; exit 2; }
exec bash "$ROOT/launch/run_ros_node.sh" --package "$PACKAGE" --executable "$EXECUTABLE" -- "${ARGS[@]}"
