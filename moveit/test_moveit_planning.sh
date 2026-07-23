#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
PACKAGE=""
EXECUTABLE=""
ARGS=()
while (($#)); do case "$1" in --package) PACKAGE="${2:?}"; shift 2;; --executable) EXECUTABLE="${2:?}"; shift 2;; --) shift; ARGS+=("$@"); break;; -h|--help) echo '用法：test_moveit_planning.sh --package PKG --executable EXE [-- ROS 参数]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$PACKAGE" && -n "$EXECUTABLE" ]] || { echo '缺少参数' >&2; exit 2; }
exec "$ROOT/launch/run_ros_node.sh" --package "$PACKAGE" --executable "$EXECUTABLE" -- "${ARGS[@]}"
