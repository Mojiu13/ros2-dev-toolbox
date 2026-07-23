#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
TOOLBOX_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
# shellcheck source=../lib/logging.sh
source "${TOOLBOX_ROOT}/lib/logging.sh"
# shellcheck source=../lib/common.sh
source "${TOOLBOX_ROOT}/lib/common.sh"
# shellcheck source=../lib/error_handling.sh
source "${TOOLBOX_ROOT}/lib/error_handling.sh"
toolbox_enable_error_handling

CONFIG_FILE="${TOOLBOX_CONFIG_FILE:-${XDG_CONFIG_HOME:-${HOME}/.config}/ros2-dev-toolbox/toolbox.env}"
FORCE=0
ROS_DISTRO_VALUE="jazzy"
HOST_WORKSPACE_VALUE="${HOME}/ros_ws"
CONTAINER_WORKSPACE_VALUE="/root/ros_ws"
IMAGE_NAME_VALUE="ros2-jazzy-dev"
IMAGE_TAG_VALUE="latest"
CONTAINER_NAME_VALUE="ros2_jazzy"

usage() {
  cat <<'USAGE'
用法：init_toolbox_config.sh [选项]

选项：
  --output PATH                 指定本机配置文件路径
  --force                       允许覆盖已有配置
  --ros-distro NAME             ROS2 发行版，默认 jazzy
  --host-workspace PATH         宿主机工作空间，默认 ~/ros_ws
  --container-workspace PATH    容器内工作空间，默认 /root/ros_ws
  --image-name NAME             Docker 镜像名
  --image-tag TAG               Docker 镜像标签
  --container-name NAME         Docker 容器名
  -h, --help                    显示帮助
USAGE
}

while (($#)); do
  case "$1" in
    --output) CONFIG_FILE="${2:?--output 需要路径}"; shift 2 ;;
    --force) FORCE=1; shift ;;
    --ros-distro) ROS_DISTRO_VALUE="${2:?--ros-distro 需要名称}"; shift 2 ;;
    --host-workspace) HOST_WORKSPACE_VALUE="${2:?--host-workspace 需要路径}"; shift 2 ;;
    --container-workspace) CONTAINER_WORKSPACE_VALUE="${2:?--container-workspace 需要路径}"; shift 2 ;;
    --image-name) IMAGE_NAME_VALUE="${2:?--image-name 需要名称}"; shift 2 ;;
    --image-tag) IMAGE_TAG_VALUE="${2:?--image-tag 需要标签}"; shift 2 ;;
    --container-name) CONTAINER_NAME_VALUE="${2:?--container-name 需要名称}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) toolbox_die "未知参数：$1" "$TOOLBOX_EXIT_USAGE" ;;
  esac
done

CONFIG_FILE="$(toolbox_abspath "$CONFIG_FILE")"
HOST_WORKSPACE_VALUE="$(toolbox_abspath "$HOST_WORKSPACE_VALUE")"

if [[ -e "$CONFIG_FILE" && "$FORCE" != "1" ]]; then
  toolbox_die "配置已存在：$CONFIG_FILE。使用 --force 才能覆盖。" "$TOOLBOX_EXIT_CONFIG"
fi

mkdir -p "$(dirname "$CONFIG_FILE")"
TEMP_FILE="$(mktemp "${CONFIG_FILE}.tmp.XXXXXX")"
toolbox_register_cleanup rm -f "$TEMP_FILE"

write_assignment() {
  local key="$1" value="$2"
  printf '%s=%q\n' "$key" "$value" >>"$TEMP_FILE"
}

cat >"$TEMP_FILE" <<'HEADER'
# ros2-dev-toolbox 本机配置
# 由 config/init_toolbox_config.sh 生成。
# 该文件采用 Bash 变量赋值语法；不要在其中写入密码、Token 或私钥。

HEADER

write_assignment TOOLBOX_CONFIG_VERSION "1"
write_assignment ROS_DISTRO "$ROS_DISTRO_VALUE"
write_assignment ROS_DOMAIN_ID "0"
write_assignment ROS_LOCALHOST_ONLY "0"
write_assignment RMW_IMPLEMENTATION ""
printf '\n# 工作空间\n' >>"$TEMP_FILE"
write_assignment HOST_WORKSPACE "$HOST_WORKSPACE_VALUE"
write_assignment CONTAINER_WORKSPACE "$CONTAINER_WORKSPACE_VALUE"
printf '\n# Docker\n' >>"$TEMP_FILE"
write_assignment DOCKER_IMAGE_NAME "$IMAGE_NAME_VALUE"
write_assignment DOCKER_IMAGE_TAG "$IMAGE_TAG_VALUE"
write_assignment DOCKER_CONTAINER_NAME "$CONTAINER_NAME_VALUE"
write_assignment DOCKER_NETWORK_MODE "host"
write_assignment DOCKER_SHM_SIZE "2g"
printf '\n# GPU 与 GUI\n' >>"$TEMP_FILE"
write_assignment ENABLE_GPU "true"
write_assignment ENABLE_GUI "true"
write_assignment GUI_DISPLAY "${DISPLAY:-:0}"
write_assignment X11_SOCKET "/tmp/.X11-unix"
printf '\n# 网络代理（启用时请填写 URL）\n' >>"$TEMP_FILE"
write_assignment ENABLE_PROXY "false"
write_assignment HTTP_PROXY_URL ""
write_assignment HTTPS_PROXY_URL ""
write_assignment NO_PROXY_LIST "localhost,127.0.0.1"
printf '\n# 日志、归档与备份\n' >>"$TEMP_FILE"
write_assignment LOG_DIR "${XDG_STATE_HOME:-${HOME}/.local/state}/ros2-dev-toolbox/logs"
write_assignment ARCHIVE_DIR "${HOME}/ros2-dev-toolbox-archives"
write_assignment BACKUP_DIR "${HOME}/ros2-dev-toolbox-backups"

chmod 600 "$TEMP_FILE"
mv -f -- "$TEMP_FILE" "$CONFIG_FILE"
TOOLBOX_CLEANUP_STACK=()

toolbox_log_success "已创建工具箱配置：$CONFIG_FILE"
if "${SCRIPT_DIR}/validate_toolbox_config.sh" --config "$CONFIG_FILE"; then
  toolbox_log_success "配置校验通过。"
else
  toolbox_die "配置已写入，但校验失败；请按上方提示修正。" "$TOOLBOX_EXIT_CONFIG"
fi
