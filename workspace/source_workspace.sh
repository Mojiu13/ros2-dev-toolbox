#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
ROS_DISTRO_VALUE="${ROS_DISTRO:-jazzy}"
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --ros-distro) ROS_DISTRO_VALUE="${2:?}"; shift 2;;
  -h|--help) echo '用法：source source_workspace.sh [--workspace PATH] [--ros-distro NAME]'; return 0 2>/dev/null || exit 0;;
  *) echo "未知参数：$1" >&2; return 2 2>/dev/null || exit 2;; esac; done
ROS_SETUP="/opt/ros/${ROS_DISTRO_VALUE}/setup.bash"
WS_SETUP="${WORKSPACE}/install/setup.bash"
[[ -f "$ROS_SETUP" && -f "$WS_SETUP" ]] || { echo '缺少 setup.bash' >&2; return 1 2>/dev/null || exit 1; }
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf '请执行：source %q --workspace %q --ros-distro %q\n' "$0" "$WORKSPACE" "$ROS_DISTRO_VALUE"
else
  source "$ROS_SETUP"
  source "$WS_SETUP"
  export ROS_DISTRO="$ROS_DISTRO_VALUE"
fi
