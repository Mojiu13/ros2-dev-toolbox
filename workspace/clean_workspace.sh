#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
YES=0
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; -y|--yes) YES=1; shift;;
  -h|--help) echo '用法：clean_workspace.sh [--workspace PATH] [--yes]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -d "$WORKSPACE/src" ]] || { echo "拒绝清理：不是 ROS2 工作空间：$WORKSPACE" >&2; exit 1; }
paths=("$WORKSPACE/build" "$WORKSPACE/install" "$WORKSPACE/log")
printf '将删除：\n'; printf '  %s\n' "${paths[@]}"
((YES)) || { read -r -p '确认？[y/N] ' a; [[ "$a" =~ ^[Yy]$ ]] || exit 1; }
rm -rf -- "${paths[@]}"
