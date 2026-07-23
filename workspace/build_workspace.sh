#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
ROS_DISTRO_VALUE="${ROS_DISTRO:-jazzy}"
SYMLINK=1
ARGS=()
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --ros-distro) ROS_DISTRO_VALUE="${2:?}"; shift 2;;
  --no-symlink-install) SYMLINK=0; shift;; -h|--help) echo '用法：build_workspace.sh [--workspace PATH] [--no-symlink-install] [-- 额外 colcon 参数]'; exit 0;;
  --) shift; ARGS+=("$@"); break;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
source "/opt/ros/${ROS_DISTRO_VALUE}/setup.bash"
cmd=(colcon build --base-paths "$WORKSPACE/src" --build-base "$WORKSPACE/build" --install-base "$WORKSPACE/install" --log-base "$WORKSPACE/log")
((SYMLINK)) && cmd+=(--symlink-install)
exec "${cmd[@]}" "${ARGS[@]}"
