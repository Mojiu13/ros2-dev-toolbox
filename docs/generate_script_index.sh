#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
OUTPUT=""

usage() {
  cat <<'EOF'
用法：generate_script_index.sh [选项]
  --root DIR      工具箱根目录
  --output FILE   输出 Markdown，默认 docs/SCRIPT_INDEX.md
EOF
}

while (($#)); do
  case "$1" in
    --root) ROOT="${2:?缺少目录}"; shift 2 ;;
    --output) OUTPUT="${2:?缺少输出文件}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

OUTPUT="${OUTPUT:-$ROOT/docs/SCRIPT_INDEX.md}"
mkdir -p "$(dirname "$OUTPUT")"

{
  printf '# ROS2 Dev Toolbox 脚本索引\n\n'
  printf '> 自动生成时间：%s  \n' "$(date -Is)"
  printf '> 生成命令：`bash docs/generate_script_index.sh`\n\n'

  for directory in config setup docker workspace templates launch inspect ros2_control moveit diagnostics docs lib; do
    mapfile -t scripts < <(find "$ROOT/$directory" -maxdepth 1 -type f -name '*.sh' -printf '%f\n' 2>/dev/null | sort)
    ((${#scripts[@]})) || continue
    printf '## `%s/`\n\n' "$directory"
    for script in "${scripts[@]}"; do
      path="$directory/$script"
      first_comment="$(awk 'NR>1 && /^# /{sub(/^# /, ""); print; exit}' "$ROOT/$path")"
      if [[ -n "$first_comment" ]]; then
        printf -- '- `%s` — %s\n' "$path" "$first_comment"
      else
        printf -- '- `%s`\n' "$path"
      fi
    done
    printf '\n'
  done

  printf '## 统计\n\n'
  printf -- '- Shell 脚本总数：%s\n' "$(find "$ROOT" -type f -name '*.sh' -not -path '*/.git/*' | wc -l)"
} >"$OUTPUT"

printf '%s\n' "$OUTPUT"
