#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
ALLOW_FILE=""

usage() {
  cat <<'EOF'
用法：check_secrets.sh [选项]
  --root DIR       扫描根目录
  --allow-file FILE 允许命中的扩展正则，每行一条

只输出经过脱敏的可疑行，不显示等号后的具体值。
EOF
}

while (($#)); do
  case "$1" in
    --root) ROOT="${2:?缺少目录}"; shift 2 ;;
    --allow-file) ALLOW_FILE="${2:?缺少文件}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

patterns='(password|passwd|token|api[_-]?key|secret|private[_-]?key|client[_-]?secret)[[:space:]]*[:=]|BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|gh[pousr]_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}'
results="$(mktemp)"
trap 'rm -f "$results"' EXIT

grep -RInE "$patterns" "$ROOT" \
  --exclude-dir=.git \
  --exclude-dir=build \
  --exclude-dir=install \
  --exclude-dir=log \
  --exclude='*.tar' \
  --exclude='*.tar.gz' \
  --exclude='*.tar.xz' >"$results" || true

if [[ -n "$ALLOW_FILE" && -f "$ALLOW_FILE" ]]; then
  while IFS= read -r allowed; do
    [[ -n "$allowed" && "$allowed" != \#* ]] || continue
    sed -i -E "\|$allowed|d" "$results"
  done <"$ALLOW_FILE"
fi

if [[ -s "$results" ]]; then
  sed -E 's/([:=])[[:space:]]*[^[:space:]]+$/\1 <redacted>/' "$results"
  printf '发现疑似敏感信息，请人工检查。\n' >&2
  exit 1
fi

printf '未发现明显敏感信息。\n'
