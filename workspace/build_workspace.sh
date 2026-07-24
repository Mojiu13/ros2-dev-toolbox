#!/usr/bin/env bash
set -Eeuo pipefail

WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
ROS_DISTRO_VALUE="${ROS_DISTRO:-jazzy}"
SYMLINK=1
ARGS=()

while (($#)); do
  case "$1" in
    --workspace) WORKSPACE="${2:?缺少路径}"; shift 2 ;;
    --ros-distro) ROS_DISTRO_VALUE="${2:?缺少发行版}"; shift 2 ;;
    --no-symlink-install) SYMLINK=0; shift ;;
    -h|--help)
      echo '用法：build_workspace.sh [--workspace PATH] [--no-symlink-install] [-- 额外 colcon build 参数]'
      exit 0
      ;;
    --) shift; ARGS+=("$@"); break ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -d "$WORKSPACE/src" ]] || { printf '缺少源码目录：%s/src\n' "$WORKSPACE" >&2; exit 1; }
source "/opt/ros/${ROS_DISTRO_VALUE}/setup.bash"

cmd=(
  colcon --log-base "$WORKSPACE/log" build
  --base-paths "$WORKSPACE/src"
  --build-base "$WORKSPACE/build"
  --install-base "$WORKSPACE/install"
)
((SYMLINK)) && cmd+=(--symlink-install)
exec "${cmd[@]}" "${ARGS[@]}"
