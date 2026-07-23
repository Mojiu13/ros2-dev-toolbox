#!/usr/bin/env bash
set -Eeuo pipefail
PREFIX="${1:-}"
if [[ "$PREFIX" == -h || "$PREFIX" == --help ]]; then echo '用法：inspect_overlay_environment.sh [可选过滤文本]'; exit 0; fi
env | grep -E '^(AMENT_PREFIX_PATH|COLCON_PREFIX_PATH|CMAKE_PREFIX_PATH|PYTHONPATH|ROS_|RMW_)=' | sort | { if [[ -n "$PREFIX" ]]; then grep -F "$PREFIX"; else cat; fi; }
