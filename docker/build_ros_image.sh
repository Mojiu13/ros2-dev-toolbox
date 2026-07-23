#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE="${DOCKER_IMAGE_REFERENCE:-ros2-jazzy-dev:latest}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
CONTEXT="${CONTEXT:-.}"
NO_CACHE=0
PULL=0
ARGS=()
while (($#)); do
  case "$1" in
    --image) IMAGE="${2:?缺少镜像名}"; shift 2;;
    --dockerfile) DOCKERFILE="${2:?缺少路径}"; shift 2;;
    --context) CONTEXT="${2:?缺少目录}"; shift 2;;
    --no-cache) NO_CACHE=1; shift;;
    --pull) PULL=1; shift;;
    -h|--help) echo '用法：build_ros_image.sh [--image NAME:TAG] [--dockerfile PATH] [--context DIR] [--no-cache] [--pull] [-- 额外 docker build 参数]'; exit 0;;
    --) shift; ARGS+=("$@"); break;;
    *) echo "未知参数：$1" >&2; exit 2;;
  esac
done
cmd=(docker build -t "$IMAGE" -f "$DOCKERFILE")
((NO_CACHE)) && cmd+=(--no-cache)
((PULL)) && cmd+=(--pull)
cmd+=("${ARGS[@]}" "$CONTEXT")
printf '执行：'; printf '%q ' "${cmd[@]}"; printf '\n'
exec "${cmd[@]}"
