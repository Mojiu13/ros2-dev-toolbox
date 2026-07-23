#!/usr/bin/env bash
set -Eeuo pipefail
UPDATE_ONLY=0
while (($#)); do case "$1" in
  --update-only) UPDATE_ONLY=1; shift;; -h|--help) echo '用法：init_rosdep.sh [--update-only]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
command -v rosdep >/dev/null || { echo '缺少 rosdep' >&2; exit 1; }
if ((!UPDATE_ONLY)); then sudo rosdep init 2>/dev/null || true; fi
exec rosdep update
