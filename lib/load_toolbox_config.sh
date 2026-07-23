#!/usr/bin/env bash
# Load ros2-dev-toolbox configuration into the current shell.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  printf '请使用 source 加载该文件：source %q\n' "$0" >&2
  exit 2
fi

if [[ "${TOOLBOX_CONFIG_LOADED:-0}" == "1" && "${TOOLBOX_CONFIG_RELOAD:-0}" != "1" ]]; then
  return 0
fi

_TOOLBOX_LOADER_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
TOOLBOX_ROOT="$(cd -- "${_TOOLBOX_LOADER_LIB_DIR}/.." && pwd -P)"

if ! declare -F toolbox_log_error >/dev/null 2>&1; then
  # shellcheck source=logging.sh
  source "${_TOOLBOX_LOADER_LIB_DIR}/logging.sh"
fi

_TOOLBOX_CONFIG_VARIABLES=(
  TOOLBOX_CONFIG_VERSION ROS_DISTRO ROS_DOMAIN_ID ROS_LOCALHOST_ONLY RMW_IMPLEMENTATION
  HOST_WORKSPACE CONTAINER_WORKSPACE
  DOCKER_IMAGE_NAME DOCKER_IMAGE_TAG DOCKER_CONTAINER_NAME DOCKER_NETWORK_MODE DOCKER_SHM_SIZE
  ENABLE_GPU ENABLE_GUI GUI_DISPLAY X11_SOCKET
  ENABLE_PROXY HTTP_PROXY_URL HTTPS_PROXY_URL NO_PROXY_LIST
  LOG_DIR ARCHIVE_DIR BACKUP_DIR
)

declare -A _TOOLBOX_ENV_OVERRIDE_SET=()
declare -A _TOOLBOX_ENV_OVERRIDE_VALUE=()
for _toolbox_var in "${_TOOLBOX_CONFIG_VARIABLES[@]}"; do
  if [[ -v "$_toolbox_var" ]]; then
    _TOOLBOX_ENV_OVERRIDE_SET["$_toolbox_var"]=1
    _TOOLBOX_ENV_OVERRIDE_VALUE["$_toolbox_var"]="${!_toolbox_var}"
  fi
done

: "${TOOLBOX_CONFIG_VERSION:=1}"
: "${ROS_DISTRO:=jazzy}"
: "${ROS_DOMAIN_ID:=0}"
: "${ROS_LOCALHOST_ONLY:=0}"
: "${RMW_IMPLEMENTATION:=}"
: "${HOST_WORKSPACE:=${HOME}/ros_ws}"
: "${CONTAINER_WORKSPACE:=/root/ros_ws}"
: "${DOCKER_IMAGE_NAME:=ros2-jazzy-dev}"
: "${DOCKER_IMAGE_TAG:=latest}"
: "${DOCKER_CONTAINER_NAME:=ros2_jazzy}"
: "${DOCKER_NETWORK_MODE:=host}"
: "${DOCKER_SHM_SIZE:=2g}"
: "${ENABLE_GPU:=true}"
: "${ENABLE_GUI:=true}"
: "${GUI_DISPLAY:=${DISPLAY:-:0}}"
: "${X11_SOCKET:=/tmp/.X11-unix}"
: "${ENABLE_PROXY:=false}"
: "${HTTP_PROXY_URL:=}"
: "${HTTPS_PROXY_URL:=}"
: "${NO_PROXY_LIST:=localhost,127.0.0.1}"
: "${LOG_DIR:=${XDG_STATE_HOME:-${HOME}/.local/state}/ros2-dev-toolbox/logs}"
: "${ARCHIVE_DIR:=${HOME}/ros2-dev-toolbox-archives}"
: "${BACKUP_DIR:=${HOME}/ros2-dev-toolbox-backups}"

TOOLBOX_CONFIG_FILE="${TOOLBOX_CONFIG_FILE:-${XDG_CONFIG_HOME:-${HOME}/.config}/ros2-dev-toolbox/toolbox.env}"
if [[ ! -f "$TOOLBOX_CONFIG_FILE" ]]; then
  toolbox_log_error "工具箱配置不存在：$TOOLBOX_CONFIG_FILE"
  toolbox_log_error "请先运行：${TOOLBOX_ROOT}/config/init_toolbox_config.sh"
  return 3
fi

set -a
# shellcheck disable=SC1090
if ! source "$TOOLBOX_CONFIG_FILE"; then
  set +a
  toolbox_log_error "工具箱配置加载失败：$TOOLBOX_CONFIG_FILE"
  return 3
fi
set +a

for _toolbox_var in "${_TOOLBOX_CONFIG_VARIABLES[@]}"; do
  if [[ "${_TOOLBOX_ENV_OVERRIDE_SET[$_toolbox_var]:-0}" == "1" ]]; then
    printf -v "$_toolbox_var" '%s' "${_TOOLBOX_ENV_OVERRIDE_VALUE[$_toolbox_var]}"
  fi
  export "$_toolbox_var"
done

DOCKER_IMAGE_REFERENCE="${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
export TOOLBOX_ROOT TOOLBOX_CONFIG_FILE DOCKER_IMAGE_REFERENCE
export TOOLBOX_CONFIG_LOADED=1

unset _toolbox_var
unset _TOOLBOX_ENV_OVERRIDE_SET _TOOLBOX_ENV_OVERRIDE_VALUE
