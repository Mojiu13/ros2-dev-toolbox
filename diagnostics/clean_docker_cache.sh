#!/usr/bin/env bash
set -Eeuo pipefail

UNTIL="168h"
EXECUTE=0
YES=0
ALL=0

usage() {
  cat <<'EOF'
用法：clean_docker_cache.sh [选项]
  --until DURATION   仅清理早于指定时长的构建缓存，默认 168h
  --all              包含所有未使用构建缓存
  --execute          实际执行；默认只显示占用与计划
  --yes              跳过确认
EOF
}

while (($#)); do
  case "$1" in
    --until) UNTIL="${2:?缺少时长}"; shift 2 ;;
    --all) ALL=1; shift ;;
    --execute) EXECUTE=1; shift ;;
    -y|--yes) YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

command -v docker >/dev/null || { printf '缺少 docker\n' >&2; exit 1; }
docker system df
cmd=(docker builder prune --filter "until=$UNTIL")
((ALL)) && cmd+=(--all)
printf '计划命令：'; printf '%q ' "${cmd[@]}"; printf '\n'

((EXECUTE)) || exit 0
if ((!YES)); then
  read -r -p '确认清理 Docker 构建缓存？[y/N] ' answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 1
fi
exec "${cmd[@]}" --force
