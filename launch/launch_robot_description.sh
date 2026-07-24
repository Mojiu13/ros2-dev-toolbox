#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE="${ROBOT_DESCRIPTION_PACKAGE:-}"
FILE="${ROBOT_DESCRIPTION_LAUNCH_FILE:-display.launch.py}"
ARGS=()

while (($#)); do
  case "$1" in
    --package) PACKAGE="${2:?缺少包名}"; shift 2 ;;
    --launch-file) FILE="${2:?缺少 Launch 文件}"; shift 2 ;;
    --) shift; ARGS+=("$@"); break ;;
    -h|--help)
      echo '用法：launch_robot_description.sh --package PKG [--launch-file FILE] [-- launch 参数]'
      exit 0
      ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -n "$PACKAGE" ]] || { printf '缺少 --package 或 ROBOT_DESCRIPTION_PACKAGE\n' >&2; exit 2; }
exec bash "${SCRIPT_DIR}/run_ros_launch.sh" --package "$PACKAGE" --launch-file "$FILE" -- "${ARGS[@]}"
