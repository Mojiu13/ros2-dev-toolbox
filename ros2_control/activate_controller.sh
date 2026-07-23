#!/usr/bin/env bash
set -Eeuo pipefail
CONTROLLER=""
MANAGER="${CONTROLLER_MANAGER:-/controller_manager}"
while (($#)); do case "$1" in --controller) CONTROLLER="${2:?}"; shift 2;; --manager) MANAGER="${2:?}"; shift 2;; -h|--help) echo '用法：activate_controller.sh --controller NAME [--manager PATH]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$CONTROLLER" ]] || { echo '缺少 --controller' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
exec ros2 control set_controller_state -c "$MANAGER" "$CONTROLLER" active
