#!/usr/bin/env bash
set -Eeuo pipefail
OUTPUT_DIR="${OUTPUT_DIR:-$PWD}"
TIMEOUT=5
while (($#)); do case "$1" in --output-dir) OUTPUT_DIR="${2:?}"; shift 2;; --timeout) TIMEOUT="${2:?}"; shift 2;; -h|--help) echo '用法：inspect_tf_tree.sh [--output-dir DIR] [--timeout 秒]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
mkdir -p "$OUTPUT_DIR"
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
cd "$OUTPUT_DIR"
exec ros2 run tf2_tools view_frames --timeout "$TIMEOUT"
