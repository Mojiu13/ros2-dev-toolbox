#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
ROS_DISTRO_VALUE="${ROS_DISTRO:-jazzy}"
SHELL_CMD="${SHELL:-bash}"
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --ros-distro) ROS_DISTRO_VALUE="${2:?}"; shift 2;; --shell) SHELL_CMD="${2:?}"; shift 2;;
  -h|--help) echo '用法：open_ros_terminal.sh [--workspace PATH] [--ros-distro NAME] [--shell CMD]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
cmd="source /opt/ros/${ROS_DISTRO_VALUE}/setup.bash; [[ -f '${WORKSPACE}/install/setup.bash' ]] && source '${WORKSPACE}/install/setup.bash'; cd '${WORKSPACE}'; exec '${SHELL_CMD}'"
exec "$SHELL_CMD" -lc "$cmd"
