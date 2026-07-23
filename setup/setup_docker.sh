#!/usr/bin/env bash
set -Eeuo pipefail

START=0
while (($#)); do
  case "$1" in
    --start) START=1; shift;;
    -h|--help) echo '用法：setup_docker.sh [--start]'; exit 0;;
    *) echo "未知参数：$1" >&2; exit 2;;
  esac
done
if ! command -v docker >/dev/null 2>&1; then
  echo '未检测到 Docker。请先运行 install_host_dependencies.sh，并按 Docker 官方仓库方式安装 Docker Engine。' >&2
  exit 1
fi
docker --version
docker info >/dev/null 2>&1 && echo 'Docker daemon: available' || echo 'Docker daemon: unavailable'
if ((START)); then
  sudo systemctl enable --now docker
  docker info >/dev/null
fi
