#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
PACKAGE=""
FILE=""
ARGS=()
while (($#)); do case "$1" in --package) PACKAGE="${2:?}"; shift 2;; --launch-file) FILE="${2:?}"; shift 2;; --) shift; ARGS+=("$@"); break;; -h|--help) echo '用法：launch_ros2_control.sh --package PKG --launch-file FILE [-- launch 参数]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$PACKAGE" && -n "$FILE" ]] || { echo '缺少参数' >&2; exit 2; }
exec "$ROOT/launch/run_ros_launch.sh" --package "$PACKAGE" --launch-file "$FILE" -- "${ARGS[@]}"
