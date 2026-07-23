#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
PACKAGE=""
ARGS=()
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --package) PACKAGE="${2:?}"; shift 2;;
  -h|--help) echo '用法：build_package.sh --package NAME [--workspace PATH] [-- 额外 colcon 参数]'; exit 0;;
  --) shift; ARGS+=("$@"); break;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$PACKAGE" ]] || { echo '缺少 --package' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
exec colcon build --base-paths "$WORKSPACE/src" --build-base "$WORKSPACE/build" --install-base "$WORKSPACE/install" --log-base "$WORKSPACE/log" --packages-select "$PACKAGE" --symlink-install "${ARGS[@]}"
