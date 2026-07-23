#!/usr/bin/env bash
# Shared error and cleanup handling for ros2-dev-toolbox.

if [[ -n "${TOOLBOX_ERROR_HANDLING_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly TOOLBOX_ERROR_HANDLING_SH_LOADED=1

_TOOLBOX_ERROR_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
if ! declare -F toolbox_log_error >/dev/null 2>&1; then
  # shellcheck source=logging.sh
  source "${_TOOLBOX_ERROR_LIB_DIR}/logging.sh"
fi

readonly TOOLBOX_EXIT_OK=0
readonly TOOLBOX_EXIT_GENERAL=1
readonly TOOLBOX_EXIT_USAGE=2
readonly TOOLBOX_EXIT_CONFIG=3
readonly TOOLBOX_EXIT_DEPENDENCY=4
readonly TOOLBOX_EXIT_STATE=5
readonly TOOLBOX_EXIT_CANCELLED=130

declare -ag TOOLBOX_CLEANUP_STACK=()
_TOOLBOX_CLEANUP_RAN=0
_TOOLBOX_ERROR_HANDLING_ENABLED=0

toolbox_register_cleanup() {
  (($# > 0)) || return 0
  local quoted=''
  printf -v quoted '%q ' "$@"
  TOOLBOX_CLEANUP_STACK+=("$quoted")
}

toolbox_run_cleanups() {
  [[ "$_TOOLBOX_CLEANUP_RAN" == "1" ]] && return 0
  _TOOLBOX_CLEANUP_RAN=1

  local i
  for ((i = ${#TOOLBOX_CLEANUP_STACK[@]} - 1; i >= 0; i--)); do
    eval -- "${TOOLBOX_CLEANUP_STACK[$i]}" || \
      toolbox_log_warn "清理动作失败：${TOOLBOX_CLEANUP_STACK[$i]}"
  done
}

_toolbox_error_handler() {
  local status="$1"
  local line="$2"
  local command_text="$3"
  trap - ERR
  toolbox_log_error "未处理错误：退出码=${status}，行=${line}，命令=${command_text}"
  return "$status"
}

_toolbox_signal_handler() {
  local signal_name="$1"
  toolbox_log_warn "收到信号 ${signal_name}，准备安全退出。"
  toolbox_run_cleanups
  trap - "$signal_name"
  case "$signal_name" in
    INT) return 130 2>/dev/null || exit 130 ;;
    TERM) return 143 2>/dev/null || exit 143 ;;
    *) return 1 2>/dev/null || exit 1 ;;
  esac
}

_toolbox_exit_handler() {
  local status="$1"
  toolbox_run_cleanups
  return "$status"
}

toolbox_enable_error_handling() {
  [[ "$_TOOLBOX_ERROR_HANDLING_ENABLED" == "1" ]] && return 0
  _TOOLBOX_ERROR_HANDLING_ENABLED=1
  set -E -o pipefail
  trap '_toolbox_error_handler "$?" "$LINENO" "$BASH_COMMAND"' ERR
  trap '_toolbox_signal_handler INT' INT
  trap '_toolbox_signal_handler TERM' TERM
  trap '_toolbox_exit_handler "$?"' EXIT
}

toolbox_disable_error_handling() {
  trap - ERR INT TERM EXIT
  _TOOLBOX_ERROR_HANDLING_ENABLED=0
}

toolbox_die() {
  local message="$1"
  local status="${2:-$TOOLBOX_EXIT_GENERAL}"
  toolbox_log_error "$message"
  exit "$status"
}

toolbox_recoverable_error() {
  local message="$1"
  local status="${2:-$TOOLBOX_EXIT_GENERAL}"
  toolbox_log_warn "$message"
  return "$status"
}

toolbox_require_success() {
  local status="$1"
  local message="${2:-前一步操作失败。}"
  (( status == 0 )) || toolbox_die "$message" "$status"
}

if [[ "${TOOLBOX_AUTO_ERROR_HANDLING:-0}" == "1" ]]; then
  toolbox_enable_error_handling
fi
