#!/usr/bin/env bash
set -Eeuo pipefail
INPUT=""
OUTPUT="${TMPDIR:-/tmp}/robot_description.urdf"
ARGS=()
while (($#)); do case "$1" in --input) INPUT="${2:?}"; shift 2;; --output) OUTPUT="${2:?}"; shift 2;; -h|--help) echo '用法：validate_robot_description.sh --input FILE.xacro [--output FILE.urdf] [-- xacro 参数]'; exit 0;; --) shift; ARGS+=("$@"); break;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -f "$INPUT" ]] || { echo '输入文件不存在' >&2; exit 1; }
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
xacro "$INPUT" -o "$OUTPUT" "${ARGS[@]}"
check_urdf "$OUTPUT"
echo "Generated: $OUTPUT"
