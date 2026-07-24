#!/usr/bin/env bash
set -Eeuo pipefail

REPOSITORY="${TOOLBOX_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
OUTPUT=""
INCLUDE_DIFF=0

usage() {
  cat <<'EOF'
用法：record_git_state.sh [选项]
  --repository DIR   Git 仓库路径
  --output FILE      输出文件
  --include-diff     同时保存未提交 diff
EOF
}

while (($#)); do
  case "$1" in
    --repository) REPOSITORY="${2:?缺少仓库路径}"; shift 2 ;;
    --output) OUTPUT="${2:?缺少输出文件}"; shift 2 ;;
    --include-diff) INCLUDE_DIFF=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

git -C "$REPOSITORY" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  printf '不是 Git 仓库：%s\n' "$REPOSITORY" >&2
  exit 1
}

OUTPUT="${OUTPUT:-${LOG_DIR:-$HOME/.local/state/ros2-dev-toolbox/logs}/git_state_$(date +%Y%m%d_%H%M%S).txt}"
mkdir -p "$(dirname "$OUTPUT")"

{
  printf 'recorded_at: %s\n' "$(date -Is)"
  printf 'repository: %s\n\n' "$(git -C "$REPOSITORY" rev-parse --show-toplevel)"
  printf '== branch and status ==\n'
  git -C "$REPOSITORY" status --short --branch
  printf '\n== latest commit ==\n'
  git -C "$REPOSITORY" log -1 --decorate --stat
  printf '\n== remotes ==\n'
  git -C "$REPOSITORY" remote -v
  printf '\n== submodules ==\n'
  git -C "$REPOSITORY" submodule status 2>/dev/null || true
  if ((INCLUDE_DIFF)); then
    printf '\n== unstaged diff ==\n'
    git -C "$REPOSITORY" diff --no-ext-diff
    printf '\n== staged diff ==\n'
    git -C "$REPOSITORY" diff --cached --no-ext-diff
  fi
} >"$OUTPUT"

printf '%s\n' "$OUTPUT"
