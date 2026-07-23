#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
REPOS_FILE=""
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --file) REPOS_FILE="${2:?}"; shift 2;;
  -h|--help) echo '用法：import_workspace_repositories.sh --file workspace.repos [--workspace PATH]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -f "$REPOS_FILE" ]] || { echo "repos 文件不存在：$REPOS_FILE" >&2; exit 1; }
mkdir -p "$WORKSPACE/src"
command -v vcs >/dev/null || { echo '缺少 vcs' >&2; exit 1; }
vcs import "$WORKSPACE/src" < "$REPOS_FILE"
