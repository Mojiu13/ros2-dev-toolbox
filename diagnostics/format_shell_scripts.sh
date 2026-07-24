#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
WRITE=0
YES=0
INDENT=2

usage() {
  cat <<'EOF'
用法：format_shell_scripts.sh [选项]
  --root DIR       扫描根目录
  --indent N       缩进宽度，默认 2
  --write          实际改写；默认只检查并显示 diff
  --yes            写入时跳过确认
EOF
}

while (($#)); do
  case "$1" in
    --root) ROOT="${2:?缺少目录}"; shift 2 ;;
    --indent) INDENT="${2:?缺少缩进宽度}"; shift 2 ;;
    --write) WRITE=1; shift ;;
    -y|--yes) YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

command -v shfmt >/dev/null || { printf '缺少 shfmt\n' >&2; exit 1; }
mapfile -d '' scripts < <(find "$ROOT" -type f -name '*.sh' -not -path '*/.git/*' -print0)
((${#scripts[@]})) || { printf '没有找到 Shell 脚本\n'; exit 0; }

if ((!WRITE)); then
  shfmt -d -i "$INDENT" -ci "${scripts[@]}"
  exit $?
fi

if ((!YES)); then
  read -r -p "格式化并改写 ${#scripts[@]} 个脚本？[y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 1
fi

shfmt -w -i "$INDENT" -ci "${scripts[@]}"
