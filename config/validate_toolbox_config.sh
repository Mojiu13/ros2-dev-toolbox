#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
TOOLBOX_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
# shellcheck source=../lib/logging.sh
source "${TOOLBOX_ROOT}/lib/logging.sh"
# shellcheck source=../lib/common.sh
source "${TOOLBOX_ROOT}/lib/common.sh"

CONFIG_FILE="${TOOLBOX_CONFIG_FILE:-${XDG_CONFIG_HOME:-${HOME}/.config}/ros2-dev-toolbox/toolbox.env}"
QUIET=0

usage() {
  cat <<'USAGE'
用法：validate_toolbox_config.sh [--config PATH] [--quiet]

校验工具箱本机配置的语法、必填项、路径、名称、布尔值和安全性。
USAGE
}

while (($#)); do
  case "$1" in
    --config) CONFIG_FILE="${2:?--config 需要路径}"; shift 2 ;;
    --quiet) QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) toolbox_log_error "未知参数：$1"; usage >&2; exit 2 ;;
  esac
done

[[ "$QUIET" == "1" ]] && TOOLBOX_QUIET=1
export TOOLBOX_QUIET

if [[ ! -f "$CONFIG_FILE" ]]; then
  toolbox_log_error "配置文件不存在：$CONFIG_FILE"
  exit 3
fi

ERRORS=0
WARNINGS=0
error() { toolbox_log_error "$*"; ((ERRORS += 1)); }
warn() { toolbox_log_warn "$*"; ((WARNINGS += 1)); }

INVALID_LINES_FILE="$(mktemp)"
trap 'rm -f "$INVALID_LINES_FILE"' EXIT
if grep -nEv '^[[:space:]]*(#.*)?$|^[A-Z][A-Z0-9_]*=' "$CONFIG_FILE" >"$INVALID_LINES_FILE" 2>/dev/null; then
  while IFS= read -r invalid_line; do
    error "非法配置行：$invalid_line"
  done <"$INVALID_LINES_FILE"
fi

DUPLICATES="$(awk -F= '/^[A-Z][A-Z0-9_]*=/{count[$1]++} END{for(k in count) if(count[k]>1) print k}' "$CONFIG_FILE")"
if [[ -n "$DUPLICATES" ]]; then
  while IFS= read -r key; do
    error "变量重复定义：$key"
  done <<<"$DUPLICATES"
fi

if ! (set -a; source "$CONFIG_FILE"; set +a) 2>/dev/null; then
  error "配置文件无法被 Bash 正确加载，请检查引号和转义。"
else
  set -a
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
  set +a
fi

required_vars=(
  TOOLBOX_CONFIG_VERSION ROS_DISTRO ROS_DOMAIN_ID ROS_LOCALHOST_ONLY
  HOST_WORKSPACE CONTAINER_WORKSPACE
  DOCKER_IMAGE_NAME DOCKER_IMAGE_TAG DOCKER_CONTAINER_NAME DOCKER_NETWORK_MODE DOCKER_SHM_SIZE
  ENABLE_GPU ENABLE_GUI GUI_DISPLAY X11_SOCKET ENABLE_PROXY NO_PROXY_LIST
  LOG_DIR ARCHIVE_DIR BACKUP_DIR
)
for var_name in "${required_vars[@]}"; do
  if [[ ! -v "$var_name" || -z "${!var_name}" ]]; then
    error "缺少必填变量：$var_name"
  fi
done

for bool_name in ENABLE_GPU ENABLE_GUI ENABLE_PROXY; do
  if [[ -v "$bool_name" && ! "${!bool_name}" =~ ^(true|false)$ ]]; then
    error "布尔变量 $bool_name 只能是 true 或 false。"
  fi
done

if [[ -v ROS_LOCALHOST_ONLY && ! "$ROS_LOCALHOST_ONLY" =~ ^[01]$ ]]; then
  error "ROS_LOCALHOST_ONLY 只能是 0 或 1。"
fi
if [[ -v ROS_DOMAIN_ID && ( ! "$ROS_DOMAIN_ID" =~ ^[0-9]+$ || "$ROS_DOMAIN_ID" -gt 232 ) ]]; then
  error "ROS_DOMAIN_ID 必须是 0 到 232 的整数。"
fi
if [[ -v ROS_DISTRO && ! "$ROS_DISTRO" =~ ^[a-z][a-z0-9_]*$ ]]; then
  error "ROS_DISTRO 格式非法：$ROS_DISTRO"
fi

for path_name in HOST_WORKSPACE CONTAINER_WORKSPACE X11_SOCKET LOG_DIR ARCHIVE_DIR BACKUP_DIR; do
  if [[ -v "$path_name" && "${!path_name}" != /* ]]; then
    error "$path_name 必须使用绝对路径：${!path_name}"
  fi
done

if [[ -v HOST_WORKSPACE && -v CONTAINER_WORKSPACE && "$HOST_WORKSPACE" == "$CONTAINER_WORKSPACE" ]]; then
  warn "HOST_WORKSPACE 与 CONTAINER_WORKSPACE 完全相同；请确认没有混用宿主机与容器路径。"
fi
if [[ -v DOCKER_IMAGE_NAME && ! "$DOCKER_IMAGE_NAME" =~ ^[a-z0-9]+([._/-][a-z0-9]+)*$ ]]; then
  error "DOCKER_IMAGE_NAME 格式非法：$DOCKER_IMAGE_NAME"
fi
if [[ -v DOCKER_IMAGE_TAG && ! "$DOCKER_IMAGE_TAG" =~ ^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$ ]]; then
  error "DOCKER_IMAGE_TAG 格式非法：$DOCKER_IMAGE_TAG"
fi
if [[ -v DOCKER_CONTAINER_NAME && ! "$DOCKER_CONTAINER_NAME" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]+$ ]]; then
  error "DOCKER_CONTAINER_NAME 格式非法：$DOCKER_CONTAINER_NAME"
fi
if [[ -v DOCKER_SHM_SIZE && ! "$DOCKER_SHM_SIZE" =~ ^[0-9]+[kKmMgG]?$ ]]; then
  error "DOCKER_SHM_SIZE 格式非法，应类似 512m 或 2g。"
fi

if [[ "${ENABLE_PROXY:-false}" == "true" && -z "${HTTP_PROXY_URL:-}${HTTPS_PROXY_URL:-}" ]]; then
  error "ENABLE_PROXY=true，但 HTTP_PROXY_URL 和 HTTPS_PROXY_URL 均为空。"
fi

if grep -Ein '^[A-Z0-9_]*(PASSWORD|PASSWD|TOKEN|SECRET|PRIVATE_KEY|API_KEY)[A-Z0-9_]*=[^[:space:]]+' "$CONFIG_FILE" >/dev/null; then
  error "配置文件疑似包含密码、Token、密钥或私钥；请改用安全注入机制。"
fi

if (( ERRORS > 0 )); then
  toolbox_log_error "配置校验失败：${ERRORS} 个错误，${WARNINGS} 个警告。"
  exit 3
fi

toolbox_log_success "配置有效：$CONFIG_FILE（${WARNINGS} 个警告）"
