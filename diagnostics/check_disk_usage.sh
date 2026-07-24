#!/usr/bin/env bash
set -Eeuo pipefail

WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
LOG_ROOT="${LOG_DIR:-$HOME/.local/state/ros2-dev-toolbox/logs}"
ARCHIVE_ROOT="${ARCHIVE_DIR:-$HOME/.local/state/ros2-dev-toolbox/archives}"
DEPTH=2

usage() {
  cat <<'EOF'
用法：check_disk_usage.sh [选项]
  --workspace PATH
  --log-root PATH
  --archive-root PATH
  --depth N          du 统计深度，默认 2
EOF
}

while (($#)); do
  case "$1" in
    --workspace) WORKSPACE="${2:?缺少路径}"; shift 2 ;;
    --log-root) LOG_ROOT="${2:?缺少路径}"; shift 2 ;;
    --archive-root) ARCHIVE_ROOT="${2:?缺少路径}"; shift 2 ;;
    --depth) DEPTH="${2:?缺少深度}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

printf '== Filesystems ==\n'
df -h

for path in "$WORKSPACE" "$LOG_ROOT" "$ARCHIVE_ROOT"; do
  if [[ -e "$path" ]]; then
    printf '\n== %s ==\n' "$path"
    du -h --max-depth="$DEPTH" "$path" 2>/dev/null | sort -h | tail -30
  fi
done

if command -v docker >/dev/null 2>&1; then
  printf '\n== Docker ==\n'
  docker system df 2>/dev/null || true
fi
