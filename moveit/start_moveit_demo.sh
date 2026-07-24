#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
PACKAGE="${MOVEIT_DEMO_PACKAGE:-moveit_resources_panda_moveit_config}"
FILE="${MOVEIT_DEMO_LAUNCH_FILE:-demo.launch.py}"
ARGS=()
while (($#)); do
  case "$1" in
    --package) PACKAGE="${2:?缺少包名}"; shift 2 ;;
    --launch-file) FILE="${2:?缺少 Launch 文件}"; shift 2 ;;
    --) shift; ARGS+=("$@"); break ;;
    -h|--help) echo '用法：start_moveit_demo.sh [--package PKG] [--launch-file FILE] [-- launch 参数]'; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done
exec bash "$ROOT/launch/run_ros_launch.sh" --package "$PACKAGE" --launch-file "$FILE" -- "${ARGS[@]}"
