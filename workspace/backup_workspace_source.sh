#!/usr/bin/env bash
set -Eeuo pipefail

WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
OUTPUT=""
INCLUDE_METADATA=1

usage() {
  cat <<'EOF'
用法：backup_workspace_source.sh [选项]
  --workspace PATH   ROS2 工作空间
  --output FILE      输出 tar.gz
  --source-only      只备份 src，不包含工作空间顶层元数据
EOF
}

while (($#)); do
  case "$1" in
    --workspace) WORKSPACE="${2:?缺少路径}"; shift 2 ;;
    --output) OUTPUT="${2:?缺少输出文件}"; shift 2 ;;
    --source-only) INCLUDE_METADATA=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -d "$WORKSPACE/src" ]] || { printf '缺少工作空间源码目录：%s/src\n' "$WORKSPACE" >&2; exit 1; }
backup_root="${BACKUP_DIR:-$HOME/.local/state/ros2-dev-toolbox/backups}"
OUTPUT="${OUTPUT:-${backup_root}/ros_ws_source_$(date +%Y%m%d_%H%M%S).tar.gz}"
mkdir -p "$(dirname "$OUTPUT")"

entries=(src)
if ((INCLUDE_METADATA)); then
  for candidate in README.md workspace.repos .repos COLCON_IGNORE; do
    [[ -e "$WORKSPACE/$candidate" ]] && entries+=("$candidate")
  done
fi

tar -C "$WORKSPACE" -czf "$OUTPUT" "${entries[@]}"
tar -tf "$OUTPUT" >/dev/null
printf '%s\n' "$OUTPUT"
