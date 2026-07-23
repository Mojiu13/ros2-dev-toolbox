#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
ROS_DISTRO_VALUE="${ROS_DISTRO:-jazzy}"
ARGS=()
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --ros-distro) ROS_DISTRO_VALUE="${2:?}"; shift 2;;
  -h|--help) echo '用法：install_workspace_dependencies.sh [--workspace PATH] [--ros-distro NAME] [-- 额外 rosdep 参数]'; exit 0;;
  --) shift; ARGS+=("$@"); break;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -d "$WORKSPACE/src" ]] || { echo "缺少 $WORKSPACE/src" >&2; exit 1; }
exec rosdep install --from-paths "$WORKSPACE/src" --ignore-src -r -y --rosdistro "$ROS_DISTRO_VALUE" "${ARGS[@]}"
