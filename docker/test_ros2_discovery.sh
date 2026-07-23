#!/usr/bin/env bash
set -Eeuo pipefail
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
ROS_DISTRO_VALUE="${ROS_DISTRO:-jazzy}"
DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
while (($#)); do case "$1" in
  --container) CONTAINER="${2:?}"; shift 2;; --ros-distro) ROS_DISTRO_VALUE="${2:?}"; shift 2;; --domain-id) DOMAIN_ID="${2:?}"; shift 2;;
  -h|--help) echo '用法：test_ros2_discovery.sh [--container NAME] [--ros-distro jazzy] [--domain-id N]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
exec docker exec -e "ROS_DOMAIN_ID=$DOMAIN_ID" "$CONTAINER" bash -lc "source /opt/ros/${ROS_DISTRO_VALUE}/setup.bash && ros2 node list && ros2 topic list"
