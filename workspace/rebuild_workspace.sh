#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
YES=0
ARGS=()
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; -y|--yes) YES=1; shift;;
  -h|--help) echo '用法：rebuild_workspace.sh [--workspace PATH] [--yes] [-- 额外 colcon 参数]'; exit 0;;
  --) shift; ARGS+=("$@"); break;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
clean_args=(--workspace "$WORKSPACE"); ((YES)) && clean_args+=(--yes)
"${SCRIPT_DIR}/clean_workspace.sh" "${clean_args[@]}"
exec "${SCRIPT_DIR}/build_workspace.sh" --workspace "$WORKSPACE" -- "${ARGS[@]}"
