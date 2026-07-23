#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
PACKAGE=""
EXECUTABLE=""
ARGS=()
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --package) PACKAGE="${2:?}"; shift 2;; --executable) EXECUTABLE="${2:?}"; shift 2;;
  -h|--help) echo '用法：run_ros_node.sh --package PKG --executable EXE [--workspace PATH] [-- ROS 参数]'; exit 0;;
  --) shift; ARGS+=("$@"); break;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$PACKAGE" && -n "$EXECUTABLE" ]] || { echo '缺少 --package 或 --executable' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
[[ -f "$WORKSPACE/install/setup.bash" ]] && source "$WORKSPACE/install/setup.bash"
exec ros2 run "$PACKAGE" "$EXECUTABLE" "${ARGS[@]}"
