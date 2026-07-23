#!/usr/bin/env bash
set -Eeuo pipefail
TOPIC=""
WINDOW=100
while (($#)); do case "$1" in --topic) TOPIC="${2:?}"; shift 2;; --window) WINDOW="${2:?}"; shift 2;; -h|--help) echo '用法：measure_topic_rate.sh --topic /name [--window N]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$TOPIC" ]] || { echo '缺少 --topic' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
exec ros2 topic hz --window "$WINDOW" "$TOPIC"
