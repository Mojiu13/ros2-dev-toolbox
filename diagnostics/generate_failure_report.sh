#!/usr/bin/env bash
set -Eeuo pipefail
OUTPUT="${LOG_DIR:-$HOME/.local/state/ros2-dev-toolbox/logs}/failure_$(date +%Y%m%d_%H%M%S).md"
TITLE="ROS2 Failure Report"
NOTES=""
while (($#)); do case "$1" in --output) OUTPUT="${2:?}"; shift 2;; --title) TITLE="${2:?}"; shift 2;; --notes) NOTES="${2:?}"; shift 2;; -h|--help) echo '用法：generate_failure_report.sh [--output FILE] [--title TEXT] [--notes TEXT]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
mkdir -p "$(dirname "$OUTPUT")"
{
  echo "# $TITLE"
  echo
  echo "- Generated: $(date -Is)"
  echo "- Host: $(hostname)"
  echo "- Kernel: $(uname -r)"
  echo "- ROS_DISTRO: ${ROS_DISTRO:-unknown}"
  echo
  echo '## Notes'
  echo "${NOTES:-Not provided}"
  echo
  echo '## Git state'
  echo '```text'
  git status --short --branch 2>&1 || true
  git log -1 --oneline 2>&1 || true
  echo '```'
  echo
  echo '## Reproduction steps'
  echo '1. '
  echo
  echo '## Expected result'
  echo
  echo '## Actual result'
} > "$OUTPUT"
echo "$OUTPUT"
