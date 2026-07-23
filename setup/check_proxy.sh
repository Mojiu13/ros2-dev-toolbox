#!/usr/bin/env bash
set -Eeuo pipefail

TIMEOUT=10
URLS=(https://github.com https://packages.ros.org)
while (($#)); do
  case "$1" in
    --timeout) TIMEOUT="${2:?缺少秒数}"; shift 2;;
    --url) URLS+=("${2:?缺少 URL}"); shift 2;;
    --clear-defaults) URLS=(); shift;;
    -h|--help) echo '用法：check_proxy.sh [--timeout 秒] [--clear-defaults] [--url URL]'; exit 0;;
    *) echo "未知参数：$1" >&2; exit 2;;
  esac
done
printf '%s\n' 'Proxy environment:'
env | grep -iE '^(http|https|all|no)_proxy=' || true
failed=0
for url in "${URLS[@]}"; do
  printf '\n[%s]\n' "$url"
  curl -fsSI --max-time "$TIMEOUT" "$url" | sed -n '1,5p' || failed=1
done
exit "$failed"
