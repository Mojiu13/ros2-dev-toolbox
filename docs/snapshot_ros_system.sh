#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT="${LOG_DIR:-$HOME/.local/state/ros2-dev-toolbox/logs}/snapshots/$(date +%Y%m%d_%H%M%S)"
INCLUDE_ROBOT=0
JOINT_STATES="${JOINT_STATES_TOPIC:-/joint_states}"
MANAGER="${CONTROLLER_MANAGER:-/controller_manager}"

usage() {
  cat <<'EOF'
用法：snapshot_ros_system.sh [选项]
  --output DIR          快照目录
  --include-robot       同时采集 joint_states、controller 和硬件接口
  --joint-states TOPIC  joint_states Topic
  --manager PATH        controller manager 路径
EOF
}

while (($#)); do
  case "$1" in
    --output) OUTPUT="${2:?缺少目录}"; shift 2 ;;
    --include-robot) INCLUDE_ROBOT=1; shift ;;
    --joint-states) JOINT_STATES="${2:?缺少 Topic}"; shift 2 ;;
    --manager) MANAGER="${2:?缺少 manager 路径}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

mkdir -p "$OUTPUT"
bash "$SCRIPT_ROOT/diagnostics/collect_ros_diagnostics.sh" --output "$OUTPUT/ros"

if ((INCLUDE_ROBOT)); then
  bash "$SCRIPT_ROOT/diagnostics/collect_robot_diagnostics.sh" \
    --output "$OUTPUT/robot" \
    --joint-states "$JOINT_STATES" \
    --manager "$MANAGER"
fi

printf 'created_at=%s\n' "$(date -Is)" >"$OUTPUT/snapshot.env"
printf '%s\n' "$OUTPUT"
