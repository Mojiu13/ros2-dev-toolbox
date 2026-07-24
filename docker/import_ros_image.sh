#!/usr/bin/env bash
set -Eeuo pipefail

INPUT=""

usage() {
  cat <<'EOF'
用法：import_ros_image.sh --input FILE
支持 .tar、.tar.gz 和 .tar.xz Docker 镜像归档。
EOF
}

while (($#)); do
  case "$1" in
    --input) INPUT="${2:?缺少输入文件}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -f "$INPUT" ]] || { printf '镜像归档不存在：%s\n' "$INPUT" >&2; exit 1; }

case "$INPUT" in
  *.tar.gz|*.tgz) gzip -dc "$INPUT" | docker load ;;
  *.tar.xz|*.txz) xz -dc "$INPUT" | docker load ;;
  *) docker load -i "$INPUT" ;;
esac
