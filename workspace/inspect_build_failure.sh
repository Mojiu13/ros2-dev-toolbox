#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
LIMIT=200
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --limit) LIMIT="${2:?}"; shift 2;;
  -h|--help) echo '用法：inspect_build_failure.sh [--workspace PATH] [--limit N]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
LOG_ROOT="$WORKSPACE/log/latest_build"
[[ -d "$LOG_ROOT" ]] || { echo "找不到构建日志：$LOG_ROOT" >&2; exit 1; }
grep -RniE '(^|[^a-z])(error:|fatal:|failed|CMake Error|Traceback)' "$LOG_ROOT" 2>/dev/null | head -n "$LIMIT" || true
