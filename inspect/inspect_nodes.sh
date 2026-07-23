#!/usr/bin/env bash
set -Eeuo pipefail
NODE=""
while (($#)); do case "$1" in --node) NODE="${2:?}"; shift 2;; -h|--help) echo '用法：inspect_nodes.sh [--node /node_name]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 node list
[[ -n "$NODE" ]] && ros2 node info "$NODE"
