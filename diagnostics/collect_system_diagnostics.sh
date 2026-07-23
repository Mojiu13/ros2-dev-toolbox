#!/usr/bin/env bash
set -Eeuo pipefail
OUTPUT="${LOG_DIR:-$HOME/.local/state/ros2-dev-toolbox/logs}/system_$(date +%Y%m%d_%H%M%S)"
[[ "${1:-}" == --output ]] && OUTPUT="${2:?}"
mkdir -p "$OUTPUT"
uname -a > "$OUTPUT/uname.txt"
cat /etc/os-release > "$OUTPUT/os-release.txt" 2>/dev/null || true
lscpu > "$OUTPUT/lscpu.txt" 2>/dev/null || true
free -h > "$OUTPUT/memory.txt"
df -h > "$OUTPUT/disk.txt"
env | sort > "$OUTPUT/environment.txt"
docker info > "$OUTPUT/docker.txt" 2>&1 || true
nvidia-smi > "$OUTPUT/nvidia.txt" 2>&1 || true
echo "$OUTPUT"
