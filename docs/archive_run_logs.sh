#!/usr/bin/env bash
set -Eeuo pipefail

INPUT=""
OUTPUT=""
COMPRESSION="gz"

usage() {
  cat <<'EOF'
用法：archive_run_logs.sh --input PATH [选项]
  --output FILE          归档文件路径
  --compression gz|xz    压缩格式，默认 gz

本脚本只创建并验证归档，不删除原始日志。
EOF
}

while (($#)); do
  case "$1" in
    --input) INPUT="${2:?缺少输入路径}"; shift 2 ;;
    --output) OUTPUT="${2:?缺少输出路径}"; shift 2 ;;
    --compression) COMPRESSION="${2:?缺少压缩格式}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -e "$INPUT" ]] || { printf '输入不存在：%s\n' "$INPUT" >&2; exit 1; }
[[ "$COMPRESSION" == gz || "$COMPRESSION" == xz ]] || {
  printf '压缩格式必须是 gz 或 xz\n' >&2
  exit 2
}

base="$(basename -- "$INPUT")"
archive_root="${ARCHIVE_DIR:-$HOME/.local/state/ros2-dev-toolbox/archives}"
OUTPUT="${OUTPUT:-${archive_root}/${base}_$(date +%Y%m%d_%H%M%S).tar.${COMPRESSION}}"
mkdir -p "$(dirname "$OUTPUT")"

parent="$(cd -- "$(dirname -- "$INPUT")" && pwd -P)"
name="$(basename -- "$INPUT")"
if [[ "$COMPRESSION" == gz ]]; then
  tar -C "$parent" -czf "$OUTPUT" "$name"
else
  tar -C "$parent" -cJf "$OUTPUT" "$name"
fi

tar -tf "$OUTPUT" >/dev/null
printf '%s\n' "$OUTPUT"
