#!/usr/bin/env bash
set -Eeuo pipefail

MANIFEST_DIR=""
WORKSPACE="${HOST_WORKSPACE:-$HOME/ros_ws}"
STAGE=plan
EXECUTE=0
YES=0

usage() {
  cat <<'EOF'
用法：restore_development_environment.sh --manifest DIR [选项]
  --workspace PATH              目标 ROS2 工作空间
  --stage plan|apt|pip|repos|build|all
  --execute                     实际执行；默认只显示恢复计划
  --yes                         跳过确认

建议按 apt → pip → repos → build 分阶段运行并检查结果。
EOF
}

while (($#)); do
  case "$1" in
    --manifest) MANIFEST_DIR="${2:?缺少清单目录}"; shift 2 ;;
    --workspace) WORKSPACE="${2:?缺少工作空间}"; shift 2 ;;
    --stage) STAGE="${2:?缺少阶段}"; shift 2 ;;
    --execute) EXECUTE=1; shift ;;
    -y|--yes) YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数：%s\n' "$1" >&2; exit 2 ;;
  esac
done

[[ -d "$MANIFEST_DIR" ]] || { printf '清单目录不存在：%s\n' "$MANIFEST_DIR" >&2; exit 1; }
[[ "$STAGE" =~ ^(plan|apt|pip|repos|build|all)$ ]] || { printf '恢复阶段无效：%s\n' "$STAGE" >&2; exit 2; }

printf 'Manifest: %s\nWorkspace: %s\nStage: %s\n' "$MANIFEST_DIR" "$WORKSPACE" "$STAGE"
printf 'Available files:\n'
find "$MANIFEST_DIR" -maxdepth 1 -type f -printf '  %f\n' | sort

[[ "$STAGE" != plan ]] || exit 0
((EXECUTE)) || {
  printf '\n当前为预览模式。确认清单后加入 --execute。\n'
  exit 0
}

if ((!YES)); then
  read -r -p "执行恢复阶段 ${STAGE}？[y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 1
fi

run_apt() {
  [[ -s "$MANIFEST_DIR/apt-packages.tsv" ]] || return 0
  mapfile -t packages < <(awk -F '\t' '{print $1}' "$MANIFEST_DIR/apt-packages.tsv" | sed '/^$/d')
  ((${#packages[@]})) || return 0
  sudo apt-get update
  sudo apt-get install -y "${packages[@]}"
}

run_pip() {
  [[ -s "$MANIFEST_DIR/pip-freeze.txt" ]] || return 0
  python3 -m pip install -r "$MANIFEST_DIR/pip-freeze.txt"
}

run_repos() {
  [[ -s "$MANIFEST_DIR/workspace.repos" ]] || return 0
  command -v vcs >/dev/null || { printf '缺少 vcs\n' >&2; return 1; }
  mkdir -p "$WORKSPACE/src"
  vcs import "$WORKSPACE/src" <"$MANIFEST_DIR/workspace.repos"
}

run_build() {
  local root
  root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
  "$root/workspace/build_workspace.sh" --workspace "$WORKSPACE"
}

case "$STAGE" in
  apt) run_apt ;;
  pip) run_pip ;;
  repos) run_repos ;;
  build) run_build ;;
  all) run_apt; run_pip; run_repos; run_build ;;
esac
