#!/usr/bin/env bash
set -Eeuo pipefail

EXECUTE=0
RUNTIME=docker
while (($#)); do
  case "$1" in
    --execute) EXECUTE=1; shift;;
    --runtime) RUNTIME="${2:?缺少 runtime}"; shift 2;;
    -h|--help) echo '用法：setup_nvidia_container_toolkit.sh [--runtime docker] [--execute]'; exit 0;;
    *) echo "未知参数：$1" >&2; exit 2;;
  esac
done
command -v nvidia-ctk >/dev/null 2>&1 || { echo '缺少 nvidia-ctk' >&2; exit 1; }
printf 'sudo nvidia-ctk runtime configure --runtime=%q\nsudo systemctl restart %q\n' "$RUNTIME" "$RUNTIME"
((EXECUTE)) || exit 0
sudo nvidia-ctk runtime configure --runtime="$RUNTIME"
sudo systemctl restart "$RUNTIME"
