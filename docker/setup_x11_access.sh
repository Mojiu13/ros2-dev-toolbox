#!/usr/bin/env bash
set -Eeuo pipefail
MODE=grant
USER_NAME="${USER}"
while (($#)); do case "$1" in
  --user) USER_NAME="${2:?}"; shift 2;; --revoke) MODE=revoke; shift;;
  -h|--help) echo '用法：setup_x11_access.sh [--user USER] [--revoke]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
command -v xhost >/dev/null || { echo '缺少 xhost' >&2; exit 1; }
if [[ "$MODE" == grant ]]; then exec xhost "+si:localuser:${USER_NAME}"; else exec xhost "-si:localuser:${USER_NAME}"; fi
