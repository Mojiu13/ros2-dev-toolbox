#!/usr/bin/env bash
set -Eeuo pipefail
TOPIC=""
VERBOSE=0
while (($#)); do case "$1" in --topic) TOPIC="${2:?}"; shift 2;; -v|--verbose) VERBOSE=1; shift;; -h|--help) echo '用法：inspect_topics.sh [--topic /name] [--verbose]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
ros2 topic list -t
if [[ -n "$TOPIC" ]]; then args=(); ((VERBOSE))&&args+=(-v); ros2 topic info "${args[@]}" "$TOPIC"; fi
