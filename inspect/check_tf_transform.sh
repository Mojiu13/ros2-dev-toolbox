#!/usr/bin/env bash
set -Eeuo pipefail
SOURCE_FRAME=""
TARGET_FRAME=""
while (($#)); do case "$1" in --source) SOURCE_FRAME="${2:?}"; shift 2;; --target) TARGET_FRAME="${2:?}"; shift 2;; -h|--help) echo '用法：check_tf_transform.sh --source FRAME --target FRAME'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$SOURCE_FRAME" && -n "$TARGET_FRAME" ]] || { echo '缺少 --source 或 --target' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
exec ros2 run tf2_ros tf2_echo "$SOURCE_FRAME" "$TARGET_FRAME"
