#!/usr/bin/env bash
set -Eeuo pipefail

OUTPUT="${BACKUP_DIR:-$HOME/.local/state/ros2-dev-toolbox/backups}/dependency_manifest_$(date +%Y%m%d_%H%M%S)"
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
INCLUDE_DOCKER=1

usage() {
  cat <<'EOF'
用法：export_dependency_manifest.sh [选项]
  --output DIR       输出目录
  --workspace PATH   ROS2 工作空间
  --no-docker        不记录 Docker 镜像和容器信息
EOF
}

while (($#)); do
  case "$1" in
    --output) OUTPUT="${2:?缺少输出目录}"; shift 2 ;;
    --workspace) WORKSPACE="${2:?缺少工作空间}"; shift 2 ;;
    --no-docker) INCLUDE_DOCKER=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

mkdir -p "$OUTPUT"
printf 'created_at=%s\nros_distro=%s\nworkspace=%s\n' \
  "$(date -Is)" "${ROS_DISTRO:-unknown}" "$WORKSPACE" >"$OUTPUT/manifest.env"

dpkg-query -W -f='${binary:Package}\t${Version}\n' >"$OUTPUT/apt-packages.tsv" 2>/dev/null || true
python3 -m pip freeze >"$OUTPUT/pip-freeze.txt" 2>/dev/null || true

if command -v ros2 >/dev/null 2>&1; then
  ros2 pkg list >"$OUTPUT/ros2-packages.txt" 2>/dev/null || true
fi

if [[ -d "$WORKSPACE/src" ]] && command -v vcs >/dev/null 2>&1; then
  vcs export --exact "$WORKSPACE/src" >"$OUTPUT/workspace.repos" 2>/dev/null || \
    vcs export "$WORKSPACE/src" >"$OUTPUT/workspace.repos" 2>/dev/null || true
fi

if ((INCLUDE_DOCKER)) && command -v docker >/dev/null 2>&1; then
  docker image ls --digests --no-trunc >"$OUTPUT/docker-images.txt" 2>/dev/null || true
  docker ps -a --no-trunc >"$OUTPUT/docker-containers.txt" 2>/dev/null || true
fi

printf '%s\n' "$OUTPUT"
