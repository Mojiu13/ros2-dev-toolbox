#!/usr/bin/env bash
set -Eeuo pipefail

JSON=0
[[ "${1:-}" == "--json" ]] && JSON=1
if command -v nvidia-smi >/dev/null 2>&1; then
  driver="$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)"
  gpu="$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)"
  status=available
else
  driver=unknown; gpu=unknown; status=unavailable
fi
modules="$(lsmod | awk '/^nvidia/{print $1}' | paste -sd, -)"
devices="$(find /dev -maxdepth 1 -name 'nvidia*' -printf '%f ' 2>/dev/null || true)"
if ((JSON)); then
  printf '{"status":"%s","gpu":"%s","driver":"%s","modules":"%s","devices":"%s"}\n' "$status" "$gpu" "$driver" "$modules" "$devices"
else
  printf 'Status: %s\nGPU: %s\nDriver: %s\nModules: %s\nDevices: %s\n' "$status" "$gpu" "$driver" "${modules:-none}" "${devices:-none}"
fi
[[ "$status" == available ]]
