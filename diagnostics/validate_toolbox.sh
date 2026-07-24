#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
CONFIG_FILE="${TOOLBOX_CONFIG_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/ros2-dev-toolbox/toolbox.env}"
RUN_SHELLCHECK=0
FIX_PERMISSIONS=0
YES=0

usage() {
  cat <<'EOF'
用法：validate_toolbox.sh [选项]
  --root DIR             工具箱根目录
  --config FILE          本机配置文件
  --shellcheck           同时运行 ShellCheck
  --fix-permissions      给全部 .sh 增加用户可执行权限
  --yes                  修复权限时跳过确认
EOF
}

while (($#)); do
  case "$1" in
    --root) ROOT="${2:?缺少目录}"; shift 2 ;;
    --config) CONFIG_FILE="${2:?缺少配置文件}"; shift 2 ;;
    --shellcheck) RUN_SHELLCHECK=1; shift ;;
    --fix-permissions) FIX_PERMISSIONS=1; shift ;;
    -y|--yes) YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

failures=0
warnings=0
mapfile -d '' scripts < <(find "$ROOT" -type f -name '*.sh' -not -path '*/.git/*' -print0)

printf 'Shell scripts: %d\n' "${#scripts[@]}"
((${#scripts[@]})) || { printf '没有找到脚本\n' >&2; exit 1; }

printf '== Bash syntax ==\n'
for script in "${scripts[@]}"; do
  if ! bash -n "$script"; then
    printf 'syntax failed: %s\n' "$script" >&2
    failures=$((failures + 1))
  fi
  if [[ "$(head -n 1 "$script")" != '#!/usr/bin/env bash' ]]; then
    printf 'unexpected shebang: %s\n' "$script" >&2
    warnings=$((warnings + 1))
  fi
done

printf '== Workflow index coverage ==\n'
index="$ROOT/WORKFLOW_INDEX.md"
if [[ -f "$index" ]]; then
  mapfile -t indexed < <(grep -oE '`[^`]+\.sh`' "$index" | tr -d '`' | sort -u)
  for relative in "${indexed[@]}"; do
    if [[ ! -f "$ROOT/$relative" ]]; then
      printf 'indexed but missing: %s\n' "$relative" >&2
      failures=$((failures + 1))
    fi
  done

  while IFS= read -r script; do
    relative="${script#"$ROOT/"}"
    if ! printf '%s\n' "${indexed[@]}" | grep -Fxq "$relative"; then
      printf 'script not indexed: %s\n' "$relative" >&2
      warnings=$((warnings + 1))
    fi
  done < <(find "$ROOT" -type f -name '*.sh' -not -path '*/.git/*' | sort)
else
  printf 'missing: WORKFLOW_INDEX.md\n' >&2
  failures=$((failures + 1))
fi

printf '== Configuration ==\n'
if [[ -f "$CONFIG_FILE" ]]; then
  if ! bash "$ROOT/config/validate_toolbox_config.sh" --config "$CONFIG_FILE"; then
    failures=$((failures + 1))
  fi
else
  printf 'optional config missing: %s\n' "$CONFIG_FILE"
fi

if ((RUN_SHELLCHECK)); then
  printf '== ShellCheck ==\n'
  if command -v shellcheck >/dev/null 2>&1; then
    bash "$ROOT/diagnostics/lint_shell_scripts.sh" --root "$ROOT" || failures=$((failures + 1))
  else
    printf 'shellcheck unavailable\n' >&2
    warnings=$((warnings + 1))
  fi
fi

if ((FIX_PERMISSIONS)); then
  if ((!YES)); then
    read -r -p "给 ${#scripts[@]} 个脚本增加用户可执行权限？[y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || exit 1
  fi
  chmod u+x "${scripts[@]}"
fi

printf 'Failures: %d\nWarnings: %d\n' "$failures" "$warnings"
((failures == 0))
