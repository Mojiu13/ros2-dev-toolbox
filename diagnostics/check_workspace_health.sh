#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
[[ "${1:-}" == --workspace ]] && WORKSPACE="${2:?}"
[[ -d "$WORKSPACE/src" ]] || { echo "缺少工作空间：$WORKSPACE/src" >&2; exit 1; }
printf 'packages: %s\n' "$(find "$WORKSPACE/src" -name package.xml | wc -l)"
for d in build install log; do [[ -d "$WORKSPACE/$d" ]] && echo "$d: present" || echo "$d: missing"; done
[[ -f "$WORKSPACE/install/setup.bash" ]] || exit 1
