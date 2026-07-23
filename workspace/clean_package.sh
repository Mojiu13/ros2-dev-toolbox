#!/usr/bin/env bash
set -Eeuo pipefail
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
PACKAGE=""
YES=0
while (($#)); do case "$1" in
  --workspace) WORKSPACE="${2:?}"; shift 2;; --package) PACKAGE="${2:?}"; shift 2;; -y|--yes) YES=1; shift;;
  -h|--help) echo '用法：clean_package.sh --package NAME [--workspace PATH] [--yes]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$PACKAGE" && "$PACKAGE" != */* ]] || { echo '包名无效' >&2; exit 2; }
paths=("$WORKSPACE/build/$PACKAGE" "$WORKSPACE/install/$PACKAGE")
printf '将删除：\n'; printf '  %s\n' "${paths[@]}"
((YES)) || { read -r -p '确认？[y/N] ' a; [[ "$a" =~ ^[Yy]$ ]] || exit 1; }
rm -rf -- "${paths[@]}"
