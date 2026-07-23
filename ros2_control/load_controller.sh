#!/usr/bin/env bash
set -Eeuo pipefail
CONTROLLER=""
MANAGER="${CONTROLLER_MANAGER:-/controller_manager}"
SET_STATE=""
while (($#)); do case "$1" in --controller) CONTROLLER="${2:?}"; shift 2;; --manager) MANAGER="${2:?}"; shift 2;; --set-state) SET_STATE="${2:?}"; shift 2;; -h|--help) echo '用法：load_controller.sh --controller NAME [--manager /controller_manager] [--set-state active]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$CONTROLLER" ]] || { echo '缺少 --controller' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
cmd=(ros2 control load_controller -c "$MANAGER"); [[ -n "$SET_STATE" ]] && cmd+=(--set-state "$SET_STATE"); exec "${cmd[@]}" "$CONTROLLER"
