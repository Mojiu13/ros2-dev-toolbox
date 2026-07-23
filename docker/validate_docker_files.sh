#!/usr/bin/env bash
set -Eeuo pipefail

DOCKERFILE="${DOCKERFILE:-Dockerfile}"
CONTEXT="${CONTEXT:-.}"
while (($#)); do
  case "$1" in
    --dockerfile) DOCKERFILE="${2:?缺少路径}"; shift 2;;
    --context) CONTEXT="${2:?缺少路径}"; shift 2;;
    -h|--help) echo '用法：validate_docker_files.sh [--dockerfile PATH] [--context DIR]'; exit 0;;
    *) echo "未知参数：$1" >&2; exit 2;;
  esac
done
[[ -d "$CONTEXT" ]] || { echo "构建上下文不存在：$CONTEXT" >&2; exit 1; }
[[ -f "$DOCKERFILE" ]] || { echo "Dockerfile 不存在：$DOCKERFILE" >&2; exit 1; }
grep -qE '^FROM[[:space:]]+' "$DOCKERFILE" || { echo '缺少 FROM 指令' >&2; exit 1; }
awk '/^(FROM|RUN|COPY|ADD|ENV|ARG|WORKDIR|CMD|ENTRYPOINT|USER|EXPOSE|VOLUME|HEALTHCHECK)[[:space:]]/{print NR ": " $0}' "$DOCKERFILE"
if [[ -f "$CONTEXT/.dockerignore" ]]; then echo '.dockerignore: present'; else echo '.dockerignore: missing'; fi
