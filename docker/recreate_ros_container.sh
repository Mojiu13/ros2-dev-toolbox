#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONTAINER="${DOCKER_CONTAINER_NAME:-ros2_jazzy}"
YES=0
ARGS=()

while (($#)); do
  case "$1" in
    --container)
      CONTAINER="${2:?缺少容器名}"
      ARGS+=(--container "$2")
      shift 2
      ;;
    -y|--yes) YES=1; shift ;;
    -h|--help)
      echo '用法：recreate_ros_container.sh [--container NAME] [--yes] [create 参数]'
      exit 0
      ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

if ((!YES)); then
  read -r -p "删除并重建容器 ${CONTAINER}？[y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 1
fi

docker rm -f "$CONTAINER" 2>/dev/null || true
exec bash "${SCRIPT_DIR}/create_ros_container.sh" "${ARGS[@]}"
