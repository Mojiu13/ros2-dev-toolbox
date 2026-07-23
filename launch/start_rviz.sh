#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
CONFIG=""
ARGS=()
while (($#)); do case "$1" in --workspace) WORKSPACE="${2:?}"; shift 2;; --config) CONFIG="${2:?}"; shift 2;; --) shift; ARGS+=("$@"); break;; -h|--help) echo '用法：start_rviz.sh [--config FILE] [--workspace PATH] [-- RViz 参数]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
[[ -f "$WORKSPACE/install/setup.bash" ]] && source "$WORKSPACE/install/setup.bash"
cmd=(rviz2); [[ -n "$CONFIG" ]] && cmd+=(-d "$CONFIG"); exec "${cmd[@]}" "${ARGS[@]}"
