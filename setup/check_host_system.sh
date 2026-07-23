#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
用法：check_host_system.sh [--json]
检查 Ubuntu、内核、架构、CPU、内存、磁盘、用户和基础命令。
EOF
}

OUTPUT_JSON=0
case "${1:-}" in
  --json) OUTPUT_JSON=1 ;;
  -h|--help) usage; exit 0 ;;
  "") ;;
  *) usage >&2; exit 2 ;;
esac

os_id="$(. /etc/os-release 2>/dev/null && printf '%s' "${ID:-unknown}")"
os_version="$(. /etc/os-release 2>/dev/null && printf '%s' "${VERSION_ID:-unknown}")"
kernel="$(uname -r)"
arch="$(uname -m)"
cpu_count="$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc)"
mem_kib="$(awk '/MemTotal/{print $2}' /proc/meminfo)"
disk_free="$(df -Pk / | awk 'NR==2{print $4}')"
missing=()
for cmd in bash git curl wget; do command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd"); done

if ((OUTPUT_JSON)); then
  printf '{"os":"%s","version":"%s","kernel":"%s","arch":"%s","cpu_count":%s,"memory_kib":%s,"root_free_kib":%s,"missing_commands":"%s"}\n' \
    "$os_id" "$os_version" "$kernel" "$arch" "$cpu_count" "$mem_kib" "$disk_free" "${missing[*]}"
else
  printf 'OS: %s %s\nKernel: %s\nArch: %s\nCPU: %s\nMemory: %s KiB\nRoot free: %s KiB\nUser: %s\n' \
    "$os_id" "$os_version" "$kernel" "$arch" "$cpu_count" "$mem_kib" "$disk_free" "$(id -un)"
  printf 'Missing commands: %s\n' "${missing[*]:-none}"
fi
