#!/usr/bin/env bash
set -Eeuo pipefail
MANAGER="${CONTROLLER_MANAGER:-/controller_manager}"
ACTIVATE=()
DEACTIVATE=()
STRICT=0
while (($#)); do case "$1" in --manager) MANAGER="${2:?}"; shift 2;; --activate) ACTIVATE+=("${2:?}"); shift 2;; --deactivate) DEACTIVATE+=("${2:?}"); shift 2;; --strict) STRICT=1; shift;; -h|--help) echo '用法：switch_controllers.sh [--activate NAME]... [--deactivate NAME]... [--manager PATH] [--strict]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
cmd=(ros2 control switch_controllers -c "$MANAGER")
((${#ACTIVATE[@]})) && cmd+=(--activate "${ACTIVATE[@]}")
((${#DEACTIVATE[@]})) && cmd+=(--deactivate "${DEACTIVATE[@]}")
((STRICT)) && cmd+=(--strict)
exec "${cmd[@]}"
