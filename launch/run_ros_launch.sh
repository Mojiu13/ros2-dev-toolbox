#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
PACKAGE=""
LAUNCH_FILE=""
ARGS=()
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --package) PACKAGE="${2:?}"; shift 2;; --launch-file) LAUNCH_FILE="${2:?}"; shift 2;;
  -h|--help) echo '用法：run_ros_launch.sh --package PKG --launch-file FILE [--workspace PATH] [-- launch 参数]'; exit 0;;
  --) shift; ARGS+=("$@"); break;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$PACKAGE" && -n "$LAUNCH_FILE" ]] || { echo '缺少 --package 或 --launch-file' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
[[ -f "$WORKSPACE/install/setup.bash" ]] && source "$WORKSPACE/install/setup.bash"
exec ros2 launch "$PACKAGE" "$LAUNCH_FILE" "${ARGS[@]}"
