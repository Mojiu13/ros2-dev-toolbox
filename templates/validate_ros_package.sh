#!/usr/bin/env bash
set -Eeuo pipefail
PACKAGE_DIR="${1:-}"
[[ "$PACKAGE_DIR" == -h || "$PACKAGE_DIR" == --help ]] && { echo '用法：validate_ros_package.sh PACKAGE_DIR'; exit 0; }
[[ -d "$PACKAGE_DIR" ]] || { echo '包目录不存在' >&2; exit 1; }
[[ -f "$PACKAGE_DIR/package.xml" ]] || { echo '缺少 package.xml' >&2; exit 1; }
command -v xmllint >/dev/null && xmllint --noout "$PACKAGE_DIR/package.xml"
if [[ -f "$PACKAGE_DIR/setup.py" ]]; then echo 'build_type: ament_python'; elif [[ -f "$PACKAGE_DIR/CMakeLists.txt" ]]; then echo 'build_type: ament_cmake'; else echo '缺少 setup.py 或 CMakeLists.txt' >&2; exit 1; fi
find "$PACKAGE_DIR" -maxdepth 2 -type f | sort
