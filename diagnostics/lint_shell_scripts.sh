#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
SEVERITY=style
FORMAT=tty
EXCLUDES=()

usage() {
  cat <<'EOF'
用法：lint_shell_scripts.sh [选项]
  --root DIR          扫描根目录
  --severity LEVEL    error|warning|info|style，默认 style
  --format FORMAT     shellcheck 输出格式，默认 tty
  --exclude CODE      排除规则，可重复
EOF
}

while (($#)); do
  case "$1" in
    --root) ROOT="${2:?缺少目录}"; shift 2 ;;
    --severity) SEVERITY="${2:?缺少等级}"; shift 2 ;;
    --format) FORMAT="${2:?缺少格式}"; shift 2 ;;
    --exclude) EXCLUDES+=("${2:?缺少规则编号}"); shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

command -v shellcheck >/dev/null || { printf '缺少 shellcheck\n' >&2; exit 1; }
mapfile -d '' scripts < <(find "$ROOT" -type f -name '*.sh' -not -path '*/.git/*' -print0)
((${#scripts[@]})) || { printf '没有找到 Shell 脚本\n'; exit 0; }

cmd=(shellcheck --severity="$SEVERITY" --format="$FORMAT")
if ((${#EXCLUDES[@]})); then
  joined="$(IFS=,; printf '%s' "${EXCLUDES[*]}")"
  cmd+=(--exclude="$joined")
fi
"${cmd[@]}" "${scripts[@]}"
