#!/usr/bin/env bash
set -Eeuo pipefail

TARGET="${1:-$PWD/ros2-dev-toolbox}"
FORCE=0

if [[ "$TARGET" == -h || "$TARGET" == --help ]]; then
  echo '用法：init_toolbox_repository.sh [TARGET_DIR] [--force]'
  exit 0
fi
[[ "${2:-}" == --force ]] && FORCE=1

if [[ -e "$TARGET" && ! -d "$TARGET" ]]; then
  printf '目标存在且不是目录：%s\n' "$TARGET" >&2
  exit 1
fi
mkdir -p "$TARGET"

if [[ -n "$(find "$TARGET" -mindepth 1 -maxdepth 1 -print -quit)" && "$FORCE" != 1 ]]; then
  printf '目标目录非空；使用 --force 只补齐缺失结构：%s\n' "$TARGET" >&2
  exit 1
fi

mkdir -p "$TARGET"/{config,lib,setup,docker,workspace,templates,launch,inspect,ros2_control,moveit,diagnostics,docs}

[[ -d "$TARGET/.git" ]] || git -C "$TARGET" init
[[ -f "$TARGET/README.md" ]] || printf '# ROS2 Dev Toolbox\n' >"$TARGET/README.md"
[[ -f "$TARGET/WORKFLOW_INDEX.md" ]] || printf '# Workflow Index\n' >"$TARGET/WORKFLOW_INDEX.md"
[[ -f "$TARGET/.gitignore" ]] || cat >"$TARGET/.gitignore" <<'EOF'
*.log
*.tar
*.tar.gz
*.tar.xz
.env
config/toolbox.env
build/
install/
log/
EOF

for directory in config lib setup docker workspace templates launch inspect ros2_control moveit diagnostics docs; do
  [[ -e "$TARGET/$directory/README.md" ]] || printf '# %s\n' "$directory" >"$TARGET/$directory/README.md"
done

printf '%s\n' "$(cd -- "$TARGET" && pwd -P)"
