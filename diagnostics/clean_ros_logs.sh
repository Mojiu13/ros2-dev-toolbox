#!/usr/bin/env bash
set -Eeuo pipefail

LOG_ROOT="${LOG_DIR:-$HOME/.local/state/ros2-dev-toolbox/logs}"
OLDER_THAN_DAYS=14
EXECUTE=0
YES=0

usage() {
  cat <<'EOF'
用法：clean_ros_logs.sh [选项]
  --log-root DIR       日志根目录
  --older-than DAYS    仅处理超过指定天数的文件，默认 14
  --execute            实际删除；默认只预览
  --yes                跳过确认
EOF
}

while (($#)); do
  case "$1" in
    --log-root) LOG_ROOT="${2:?缺少目录}"; shift 2 ;;
    --older-than) OLDER_THAN_DAYS="${2:?缺少天数}"; shift 2 ;;
    --execute) EXECUTE=1; shift ;;
    -y|--yes) YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ "$OLDER_THAN_DAYS" =~ ^[0-9]+$ ]] || { printf '天数必须是非负整数\n' >&2; exit 2; }
[[ -d "$LOG_ROOT" ]] || { printf '日志目录不存在：%s\n' "$LOG_ROOT" >&2; exit 1; }
resolved="$(cd -- "$LOG_ROOT" && pwd -P)"
[[ "$resolved" != / && "$resolved" != "$HOME" ]] || { printf '拒绝处理高风险目录：%s\n' "$resolved" >&2; exit 1; }

mapfile -d '' files < <(find "$resolved" -type f -mtime "+$OLDER_THAN_DAYS" -print0)
printf '匹配文件数：%d\n' "${#files[@]}"
printf '%s\n' "${files[@]}"

((EXECUTE)) || exit 0
((${#files[@]})) || exit 0
if ((!YES)); then
  read -r -p '确认删除上述文件？[y/N] ' answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 1
fi
for file in "${files[@]}"; do rm -f -- "$file"; done
find "$resolved" -depth -type d -empty -delete
