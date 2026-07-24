#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE="${DOCKER_IMAGE_REFERENCE:-ros2-jazzy-dev:latest}"
OUTPUT=""
COMPRESS=none

usage() {
  cat <<'EOF'
用法：export_ros_image.sh [选项]
  --image NAME:TAG       要导出的镜像
  --output FILE          输出文件
  --compress none|gz|xz  可选压缩格式
EOF
}

while (($#)); do
  case "$1" in
    --image) IMAGE="${2:?缺少镜像名}"; shift 2 ;;
    --output) OUTPUT="${2:?缺少输出文件}"; shift 2 ;;
    --compress) COMPRESS="${2:?缺少压缩格式}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ "$COMPRESS" == none || "$COMPRESS" == gz || "$COMPRESS" == xz ]] || {
  printf '压缩格式必须是 none、gz 或 xz\n' >&2
  exit 2
}

safe_image="$(printf '%s' "$IMAGE" | tr '/:' '__')"
backup_root="${BACKUP_DIR:-$HOME/.local/state/ros2-dev-toolbox/backups}"
ext=tar
[[ "$COMPRESS" == gz ]] && ext=tar.gz
[[ "$COMPRESS" == xz ]] && ext=tar.xz
OUTPUT="${OUTPUT:-${backup_root}/${safe_image}_$(date +%Y%m%d_%H%M%S).${ext}}"
mkdir -p "$(dirname "$OUTPUT")"

case "$COMPRESS" in
  none) docker save -o "$OUTPUT" "$IMAGE" ;;
  gz) docker save "$IMAGE" | gzip -c >"$OUTPUT" ;;
  xz) docker save "$IMAGE" | xz -c >"$OUTPUT" ;;
esac

[[ -s "$OUTPUT" ]] || { printf '导出文件为空：%s\n' "$OUTPUT" >&2; exit 1; }
printf '%s\n' "$OUTPUT"
