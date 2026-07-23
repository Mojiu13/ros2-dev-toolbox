#!/usr/bin/env bash
set -Eeuo pipefail
PIDS=()
SIGNAL=INT
YES=0
while (($#)); do case "$1" in --pid) PIDS+=("${2:?}"); shift 2;; --signal) SIGNAL="${2:?}"; shift 2;; -y|--yes) YES=1; shift;; -h|--help) echo '用法：cleanup_ros_processes.sh --pid PID [--pid PID...] [--signal INT] [--yes]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
((${#PIDS[@]})) || { echo '必须显式提供至少一个 --pid' >&2; exit 2; }
for pid in "${PIDS[@]}"; do [[ "$pid" =~ ^[0-9]+$ ]] || { echo "无效 PID：$pid" >&2; exit 2; }; ps -p "$pid" -o pid,user,cmd; done
((YES)) || { read -r -p "向这些进程发送 ${SIGNAL}？[y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || exit 1; }
kill -s "$SIGNAL" "${PIDS[@]}"
