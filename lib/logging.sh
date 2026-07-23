#!/usr/bin/env bash
# Shared logging helpers for ros2-dev-toolbox.

if [[ -n "${TOOLBOX_LOGGING_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
readonly TOOLBOX_LOGGING_SH_LOADED=1

: "${TOOLBOX_LOG_LEVEL:=INFO}"
: "${TOOLBOX_QUIET:=0}"
: "${TOOLBOX_VERBOSE:=0}"

_toolbox_log_level_value() {
  case "${1^^}" in
    DEBUG) printf '10' ;;
    INFO) printf '20' ;;
    SUCCESS) printf '25' ;;
    WARN|WARNING) printf '30' ;;
    ERROR) printf '40' ;;
    *) printf '20' ;;
  esac
}

_toolbox_log_should_emit() {
  local level="${1^^}"
  local configured="${TOOLBOX_LOG_LEVEL^^}"

  if [[ "${TOOLBOX_VERBOSE}" == "1" ]]; then
    configured="DEBUG"
  fi

  if [[ "${TOOLBOX_QUIET}" == "1" && "$level" != "WARN" && "$level" != "ERROR" ]]; then
    return 1
  fi

  (( $(_toolbox_log_level_value "$level") >= $(_toolbox_log_level_value "$configured") ))
}

_toolbox_log_source() {
  if [[ -n "${TOOLBOX_SCRIPT_NAME:-}" ]]; then
    printf '%s' "$TOOLBOX_SCRIPT_NAME"
    return 0
  fi

  local source_file candidate
  for source_file in "${BASH_SOURCE[@]:1}"; do
    candidate="$(basename "$source_file")"
    if [[ "$candidate" != "logging.sh" ]]; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  basename "$0"
}

_toolbox_log_color() {
  local level="${1^^}"
  if [[ ! -t 1 || -n "${NO_COLOR:-}" || "${TERM:-dumb}" == "dumb" ]]; then
    printf ''
    return 0
  fi

  case "$level" in
    DEBUG) printf '\033[2m' ;;
    INFO) printf '\033[36m' ;;
    SUCCESS) printf '\033[32m' ;;
    WARN) printf '\033[33m' ;;
    ERROR) printf '\033[31m' ;;
    *) printf '' ;;
  esac
}

_toolbox_log() {
  local level="${1^^}"
  shift
  local message="$*"
  local timestamp source plain_line color reset=''

  _toolbox_log_should_emit "$level" || return 0

  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  source="$(_toolbox_log_source)"
  plain_line="[$timestamp] [$level] [$source] $message"
  color="$(_toolbox_log_color "$level")"
  [[ -n "$color" ]] && reset='\033[0m'

  if [[ "$level" == "WARN" || "$level" == "ERROR" ]]; then
    printf '%b%s%b\n' "$color" "$plain_line" "$reset" >&2
  else
    printf '%b%s%b\n' "$color" "$plain_line" "$reset"
  fi

  if [[ -n "${TOOLBOX_LOG_FILE:-}" ]]; then
    mkdir -p "$(dirname "$TOOLBOX_LOG_FILE")" 2>/dev/null || true
    printf '%s\n' "$plain_line" >>"$TOOLBOX_LOG_FILE" 2>/dev/null || true
  fi
}

toolbox_log_debug() { _toolbox_log DEBUG "$@"; }
toolbox_log_info() { _toolbox_log INFO "$@"; }
toolbox_log_success() { _toolbox_log SUCCESS "$@"; }
toolbox_log_warn() { _toolbox_log WARN "$@"; }
toolbox_log_error() { _toolbox_log ERROR "$@"; }

log_debug() { toolbox_log_debug "$@"; }
log_info() { toolbox_log_info "$@"; }
log_success() { toolbox_log_success "$@"; }
log_warn() { toolbox_log_warn "$@"; }
log_error() { toolbox_log_error "$@"; }
