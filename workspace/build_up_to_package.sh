#!/usr/bin/env bash
set -Eeuo pipefail

WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
PACKAGE=""
ARGS=()

while (($#)); do
  case "$1" in
    --workspace) WORKSPACE="${2:?缺少路径}"; shift 2 ;;
    --package) PACKAGE="${2:?缺少包名}"; shift 2 ;;
    -h|--help)
      echo '用法：build_up_to_package.sh --package NAME [--workspace PATH] [-- 额外 colcon build 参数]'
      exit 0
      ;;
    --) shift; ARGS+=("$@"); break ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -n "$PACKAGE" ]] || { printf '缺少 --package\n' >&2; exit 2; }
[[ -d "$WORKSPACE/src" ]] || { printf '缺少源码目录：%s/src\n' "$WORKSPACE" >&2; exit 1; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"

exec colcon --log-base "$WORKSPACE/log" build \
  --base-paths "$WORKSPACE/src" \
  --build-base "$WORKSPACE/build" \
  --install-base "$WORKSPACE/install" \
  --packages-up-to "$PACKAGE" \
  --symlink-install \
  "${ARGS[@]}"
