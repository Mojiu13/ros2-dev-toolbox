#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
NAME=""
DEPENDENCIES=()
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --name) NAME="${2:?}"; shift 2;;
  --dependencies) read -r -a DEPENDENCIES <<< "${2:-}"; shift 2;;
  -h|--help) echo '用法：create_cpp_package.sh --name PKG [--workspace PATH] [--dependencies "rclcpp std_msgs"]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$NAME" ]] || { echo '缺少 --name' >&2; exit 2; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
mkdir -p "$WORKSPACE/src"
cmd=(ros2 pkg create --build-type ament_cmake "$NAME")
((${#DEPENDENCIES[@]})) && cmd+=(--dependencies "${DEPENDENCIES[@]}")
cd "$WORKSPACE/src"
exec "${cmd[@]}"
