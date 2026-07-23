#!/usr/bin/env bash
set -Eeuo pipefail
IMAGE="${DOCKER_IMAGE_REFERENCE:-ros2-jazzy-dev:latest}"
FORMAT=""
while (($#)); do
  case "$1" in
    --image) IMAGE="${2:?缺少镜像名}"; shift 2;;
    --format) FORMAT="${2:?缺少格式}"; shift 2;;
    -h|--help) echo '用法：inspect_ros_image.sh [--image NAME:TAG] [--format TEMPLATE]'; exit 0;;
    *) echo "未知参数：$1" >&2; exit 2;;
  esac
done
if [[ -n "$FORMAT" ]]; then docker image inspect --format "$FORMAT" "$IMAGE"; else docker image inspect "$IMAGE"; docker history "$IMAGE"; fi
