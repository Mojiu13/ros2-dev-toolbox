#!/usr/bin/env bash
# Shared utility functions for ros2-dev-toolbox.

if [[ -n "${TOOLBOX_COMMON_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly TOOLBOX_COMMON_SH_LOADED=1

_TOOLBOX_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
if ! declare -F toolbox_log_error >/dev/null 2>&1; then
  # shellcheck source=logging.sh
  source "${_TOOLBOX_LIB_DIR}/logging.sh"
fi

toolbox_repo_root() {
  cd -- "${_TOOLBOX_LIB_DIR}/.." && pwd -P
}

toolbox_timestamp() {
  date '+%Y%m%d_%H%M%S'
}

toolbox_command_exists() {
  command -v "$1" >/dev/null 2>&1
}

toolbox_require_command() {
  local command_name="$1"
  local hint="${2:-请先安装该命令后重试。}"
  if ! toolbox_command_exists "$command_name"; then
    toolbox_log_error "缺少命令：${command_name}。${hint}"
    return 127
  fi
}

toolbox_require_commands() {
  local failed=0 command_name
  for command_name in "$@"; do
    toolbox_require_command "$command_name" || failed=1
  done
  return "$failed"
}

toolbox_require_file() {
  local path="$1"
  [[ -f "$path" ]] || {
    toolbox_log_error "文件不存在：$path"
    return 1
  }
}

toolbox_require_dir() {
  local path="$1"
  [[ -d "$path" ]] || {
    toolbox_log_error "目录不存在：$path"
    return 1
  }
}

toolbox_abspath() {
  local path="$1"
  if toolbox_command_exists realpath; then
    realpath -m -- "$path"
  elif toolbox_command_exists readlink; then
    readlink -m -- "$path"
  else
    local parent base
    parent="$(dirname -- "$path")"
    base="$(basename -- "$path")"
    (cd -- "$parent" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$base")
  fi
}

toolbox_is_container() {
  [[ -f /.dockerenv || -f /run/.containerenv ]] && return 0
  grep -qaE '(docker|containerd|kubepods|podman|lxc)' /proc/1/cgroup 2>/dev/null
}

toolbox_require_host() {
  if toolbox_is_container; then
    toolbox_log_error "该操作必须在宿主机中执行。"
    return 1
  fi
}

toolbox_require_container() {
  if ! toolbox_is_container; then
    toolbox_log_error "该操作必须在容器中执行。"
    return 1
  fi
}

toolbox_require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    toolbox_log_error "该操作需要 root 权限。"
    return 1
  fi
}

toolbox_require_non_root() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    toolbox_log_error "该操作不应以 root 用户执行。"
    return 1
  fi
}

toolbox_require_workspace() {
  local workspace="${1:-${HOST_WORKSPACE:-}}"
  if [[ -z "$workspace" || ! -d "$workspace/src" ]]; then
    toolbox_log_error "不是有效的 ROS2 工作空间：${workspace:-<未设置>}（缺少 src/）。"
    return 1
  fi
}

toolbox_confirm() {
  local prompt="${1:-确认继续吗？}"
  local default="${2:-no}"
  local answer suffix

  if [[ "${TOOLBOX_ASSUME_YES:-0}" == "1" ]]; then
    return 0
  fi
  if [[ ! -t 0 ]]; then
    [[ "$default" == "yes" ]]
    return
  fi

  [[ "$default" == "yes" ]] && suffix='[Y/n]' || suffix='[y/N]'
  read -r -p "$prompt $suffix " answer
  answer="${answer:-$default}"
  [[ "$answer" =~ ^([yY]|[yY][eE][sS]|yes)$ ]]
}

toolbox_retry() {
  local attempts="$1"
  local delay_seconds="$2"
  shift 2
  local try status

  for ((try = 1; try <= attempts; try++)); do
    if "$@"; then
      return 0
    fi
    status=$?
    if (( try < attempts )); then
      toolbox_log_warn "命令失败（第 ${try}/${attempts} 次，退出码 ${status}），${delay_seconds} 秒后重试。"
      sleep "$delay_seconds"
    fi
  done
  return "$status"
}

toolbox_make_temp_dir() {
  local prefix="${1:-ros2-dev-toolbox}"
  mktemp -d "${TMPDIR:-/tmp}/${prefix}.XXXXXX"
}

toolbox_safe_exit() {
  local message="${1:-操作已取消。}"
  local status="${2:-1}"
  toolbox_log_error "$message"
  return "$status" 2>/dev/null || exit "$status"
}
