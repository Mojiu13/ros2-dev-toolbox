#!/usr/bin/env bash
set -Eeuo pipefail

CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
IMAGE="${DOCKER_IMAGE_REFERENCE:-ros2-jazzy-dev:latest}"
HOST_WS="${HOST_WORKSPACE:-$HOME/ros_ws}"
CONTAINER_WS="${CONTAINER_WORKSPACE:-/root/ros_ws}"
NETWORK="${DOCKER_NETWORK_MODE:-host}"
SHM="${DOCKER_SHM_SIZE:-2g}"
GPU="${ENABLE_GPU:-1}"
GUI="${ENABLE_GUI:-1}"
ARGS=()
while (($#)); do case "$1" in
  --container) CONTAINER="${2:?}"; shift 2;; --image) IMAGE="${2:?}"; shift 2;;
  --host-workspace) HOST_WS="${2:?}"; shift 2;; --container-workspace) CONTAINER_WS="${2:?}"; shift 2;;
  --network) NETWORK="${2:?}"; shift 2;; --shm-size) SHM="${2:?}"; shift 2;;
  --gpu) GPU="${2:?}"; shift 2;; --gui) GUI="${2:?}"; shift 2;;
  -h|--help) echo '用法：create_ros_container.sh [配置覆盖] [-- 额外 docker create 参数]'; exit 0;;
  --) shift; ARGS+=("$@"); break;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
mkdir -p "$HOST_WS"
cmd=(docker create --name "$CONTAINER" --network "$NETWORK" --shm-size "$SHM" -v "$HOST_WS:$CONTAINER_WS")
[[ "$GPU" == 1 ]] && cmd+=(--gpus all)
[[ "$GUI" == 1 ]] && cmd+=(-e "DISPLAY=${DISPLAY:-:0}" -v /tmp/.X11-unix:/tmp/.X11-unix:rw)
cmd+=("${ARGS[@]}" "$IMAGE" bash)
printf '执行：'; printf '%q ' "${cmd[@]}"; printf '\n'
exec "${cmd[@]}"
