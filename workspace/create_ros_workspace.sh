#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; -h|--help) echo '用法：create_ros_workspace.sh [--workspace PATH]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
mkdir -p "$WORKSPACE/src"
printf 'Workspace: %s\nSource: %s/src\n' "$WORKSPACE" "$WORKSPACE"
