#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
[[ "${1:-}" == --workspace ]] && WORKSPACE="${2:?}"
[[ -d "$WORKSPACE" ]] || { echo "工作空间不存在：$WORKSPACE" >&2; exit 1; }
[[ -d "$WORKSPACE/src" ]] || { echo "缺少 src：$WORKSPACE/src" >&2; exit 1; }
for d in src build install log; do
  if [[ -d "$WORKSPACE/$d" ]]; then printf '%-8s present\n' "$d"; else printf '%-8s missing\n' "$d"; fi
done
find "$WORKSPACE/src" -name package.xml -printf '%h\n' | sort
