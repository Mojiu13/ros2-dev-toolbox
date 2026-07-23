#!/usr/bin/env bash
set -Eeuo pipefail
TOPIC="${PLANNING_SCENE_TOPIC:-/monitored_planning_scene}"
ONCE=1
while (($#)); do case "$1" in --topic) TOPIC="${2:?}"; shift 2;; --follow) ONCE=0; shift;; -h|--help) echo '用法：inspect_planning_scene.sh [--topic /monitored_planning_scene] [--follow]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
cmd=(ros2 topic echo); ((ONCE)) && cmd+=(--once); exec "${cmd[@]}" "$TOPIC"
