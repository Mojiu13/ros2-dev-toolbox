#!/usr/bin/env bash
set -Eeuo pipefail
PORT=""
while (($#)); do case "$1" in --port) PORT="${2:?}"; shift 2;; -h|--help) echo '用法：inspect_network_usage.sh [--port N]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
ip addr
ip route
if [[ -n "$PORT" ]]; then ss -lntup | awk -v p=":$PORT" '$0 ~ p'; else ss -lntup; fi
command -v docker >/dev/null && docker network ls || true
