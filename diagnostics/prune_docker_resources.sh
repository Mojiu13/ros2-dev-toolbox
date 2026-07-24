#!/usr/bin/env bash
set -Eeuo pipefail

EXECUTE=0
YES=0
INCLUDE_VOLUMES=0
UNTIL="168h"

usage() {
  cat <<'EOF'
用法：prune_docker_resources.sh [选项]
  --until DURATION   仅处理早于指定时长的未使用资源，默认 168h
  --volumes          同时处理未使用 volume
  --execute          实际执行；默认只预览
  --yes              跳过确认
EOF
}

while (($#)); do
  case "$1" in
    --until) UNTIL="${2:?缺少时长}"; shift 2 ;;
    --volumes) INCLUDE_VOLUMES=1; shift ;;
    --execute) EXECUTE=1; shift ;;
    -y|--yes) YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

command -v docker >/dev/null || { printf '缺少 docker\n' >&2; exit 1; }
printf '== 当前占用 ==\n'
docker system df
printf '\n== 未使用容器 ==\n'
docker ps -a --filter status=exited --filter status=created --format '{{.ID}}\t{{.Names}}\t{{.Status}}'
printf '\n== dangling images ==\n'
docker images --filter dangling=true

cmd=(docker system prune --filter "until=$UNTIL")
((INCLUDE_VOLUMES)) && cmd+=(--volumes)
printf '\n计划命令：'; printf '%q ' "${cmd[@]}"; printf '\n'

((EXECUTE)) || exit 0
if ((!YES)); then
  read -r -p '确认清理未使用 Docker 资源？[y/N] ' answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 1
fi
exec "${cmd[@]}" --force
