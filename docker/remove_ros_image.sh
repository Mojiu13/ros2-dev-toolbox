#!/usr/bin/env bash
set -Eeuo pipefail
IMAGE="${DOCKER_IMAGE_REFERENCE:-ros2-jazzy-dev:latest}"
FORCE=0; YES=0
while (($#)); do case "$1" in
  --image) IMAGE="${2:?}"; shift 2;; --force) FORCE=1; shift;; -y|--yes) YES=1; shift;;
  -h|--help) echo '用法：remove_ros_image.sh [--image NAME:TAG] [--force] [--yes]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
((YES)) || { read -r -p "删除镜像 ${IMAGE}？[y/N] " ans; [[ "$ans" =~ ^[Yy]$ ]] || exit 1; }
cmd=(docker image rm); ((FORCE)) && cmd+=(--force); exec "${cmd[@]}" "$IMAGE"
