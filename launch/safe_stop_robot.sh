#!/usr/bin/env bash
set -Eeuo pipefail
CONTROLLER=""
PID_FILE=""
while (($#)); do case "$1" in --controller) CONTROLLER="${2:?}"; shift 2;; --pid-file) PID_FILE="${2:?}"; shift 2;; -h|--help) echo '用法：safe_stop_robot.sh [--controller NAME] [--pid-file FILE]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
if [[ -n "$CONTROLLER" ]]; then ros2 control set_controller_state "$CONTROLLER" inactive || true; fi
if [[ -n "$PID_FILE" && -f "$PID_FILE" ]]; then pid="$(cat "$PID_FILE")"; [[ "$pid" =~ ^[0-9]+$ ]] && kill -INT "$pid" || true; fi
echo '已请求停止指定 controller/进程。真实机器人还应配合厂商急停与硬件安全链。'
