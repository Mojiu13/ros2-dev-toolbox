#!/usr/bin/env bash
set -Eeuo pipefail
OUTPUT=""
PACKAGE="example_package"
EXECUTABLE="example_node"
NAME="example_node"
while (($#)); do case "$1" in
  --output) OUTPUT="${2:?}"; shift 2;; --package) PACKAGE="${2:?}"; shift 2;; --executable) EXECUTABLE="${2:?}"; shift 2;; --name) NAME="${2:?}"; shift 2;;
  -h|--help) echo '用法：create_launch_template.sh --output FILE [--package PKG] [--executable EXE] [--name NODE]'; exit 0;;
  *) echo "未知参数：$1" >&2; exit 2;; esac; done
[[ -n "$OUTPUT" ]] || { echo '缺少 --output' >&2; exit 2; }
mkdir -p "$(dirname "$OUTPUT")"
cat > "$OUTPUT" <<PY
from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    return LaunchDescription([
        Node(package='${PACKAGE}', executable='${EXECUTABLE}', name='${NAME}', output='screen'),
    ])
PY
