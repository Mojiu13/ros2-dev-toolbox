#!/usr/bin/env bash
set -Eeuo pipefail

OUTPUT_ROOT="${LOG_DIR:-$HOME/.local/state/ros2-dev-toolbox/logs}/runs"
NAME="run"
NOTES=""
CONFIG_FILE="${TOOLBOX_CONFIG_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/ros2-dev-toolbox/toolbox.env}"

usage() {
  cat <<'EOF'
用法：create_run_record.sh [选项]
  --output-root DIR   记录根目录
  --name NAME         本次运行名称
  --notes TEXT        简短备注
  --config FILE       要复制的非敏感配置文件
EOF
}

while (($#)); do
  case "$1" in
    --output-root) OUTPUT_ROOT="${2:?缺少目录}"; shift 2 ;;
    --name) NAME="${2:?缺少名称}"; shift 2 ;;
    --notes) NOTES="${2:?缺少备注}"; shift 2 ;;
    --config) CONFIG_FILE="${2:?缺少配置路径}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

safe_name="$(printf '%s' "$NAME" | tr -cs 'A-Za-z0-9._-' '_')"
record_dir="${OUTPUT_ROOT}/$(date +%Y%m%d_%H%M%S)_${safe_name}"
mkdir -p "$record_dir"

cat >"$record_dir/metadata.env" <<EOF
CREATED_AT=$(date -Is)
NAME=${safe_name}
HOSTNAME=$(hostname)
USER=$(id -un)
ROS_DISTRO=${ROS_DISTRO:-unknown}
ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-unknown}
WORKSPACE=${HOST_WORKSPACE:-unknown}
EOF

printf '%s\n' "${NOTES:-No notes provided.}" >"$record_dir/NOTES.md"

if [[ -f "$CONFIG_FILE" ]]; then
  if grep -qiE '(password|passwd|token|secret|private[_-]?key)[[:space:]]*=' "$CONFIG_FILE"; then
    printf '配置疑似含敏感字段，未复制：%s\n' "$CONFIG_FILE" >&2
  else
    cp -- "$CONFIG_FILE" "$record_dir/toolbox.env"
  fi
fi

printf '%s\n' "$record_dir"
