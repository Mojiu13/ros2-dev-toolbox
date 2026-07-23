#!/usr/bin/env bash
set -Eeuo pipefail
OUTPUT=""
NODE='/**'
while (($#)); do case "$1" in
  --output) OUTPUT="${2:?}"; shift 2;; --node) NODE="${2:?}"; shift 2;;
  -h|--help) echo '用法：create_parameter_template.sh --output FILE [--node NODE_NAME]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$OUTPUT" ]] || { echo '缺少 --output' >&2; exit 2; }
mkdir -p "$(dirname "$OUTPUT")"
printf '%s:\n  ros__parameters:\n    example_parameter: value\n' "$NODE" > "$OUTPUT"
