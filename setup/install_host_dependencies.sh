#!/usr/bin/env bash
set -Eeuo pipefail

EXECUTE=0
ASSUME_YES=0
PACKAGES=(git curl wget ca-certificates gnupg lsb-release jq x11-apps shellcheck shfmt)

usage(){ cat <<'EOF'
用法：install_host_dependencies.sh [--execute] [--yes] [--packages "pkg1 pkg2"]
默认只显示将执行的 apt 命令；只有同时指定 --execute 才会安装。
EOF
}
while (($#)); do
  case "$1" in
    --execute) EXECUTE=1; shift;;
    -y|--yes) ASSUME_YES=1; shift;;
    --packages) read -r -a PACKAGES <<< "${2:?缺少包列表}"; shift 2;;
    -h|--help) usage; exit 0;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2;;
  esac
done
printf 'sudo apt-get update\nsudo apt-get install -y %q' "${PACKAGES[0]}"
printf ' %q' "${PACKAGES[@]:1}"
printf '\n'
((EXECUTE)) || exit 0
if ((!ASSUME_YES)); then read -r -p '确认安装？[y/N] ' ans; [[ "$ans" =~ ^[Yy]$ ]] || exit 1; fi
sudo apt-get update
sudo apt-get install -y "${PACKAGES[@]}"
