#!/usr/bin/env bash
set -Eeuo pipefail
ROS_DISTRO_VALUE="${ROS_DISTRO:-jazzy}"
[[ "${1:-}" == --ros-distro ]] && ROS_DISTRO_VALUE="${2:?}"
SETUP="/opt/ros/${ROS_DISTRO_VALUE}/setup.bash"
[[ -f "$SETUP" ]] || { echo "不存在：$SETUP" >&2; return 1 2>/dev/null || exit 1; }
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf '请执行：source %q --ros-distro %q\n' "$0" "$ROS_DISTRO_VALUE"
else
  source "$SETUP"
  export ROS_DISTRO="$ROS_DISTRO_VALUE"
fi
