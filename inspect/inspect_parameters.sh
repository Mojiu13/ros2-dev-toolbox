#!/usr/bin/env bash
set -Eeuo pipefail
NODE=""
PARAM=""
while (($#)); do case "$1" in --node) NODE="${2:?}"; shift 2;; --parameter) PARAM="${2:?}"; shift 2;; -h|--help) echo '用法：inspect_parameters.sh --node /name [--parameter NAME]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$NODE" ]] || { echo '缺少 --node' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 param list "$NODE"
[[ -n "$PARAM" ]] && { ros2 param describe "$NODE" "$PARAM"; ros2 param get "$NODE" "$PARAM"; }
