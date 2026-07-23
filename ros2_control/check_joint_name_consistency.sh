#!/usr/bin/env bash
set -Eeuo pipefail
URDF=""
CONTROLLER_YAML=""
MOVEIT_YAML=""
while (($#)); do case "$1" in --urdf) URDF="${2:?}"; shift 2;; --controller-yaml) CONTROLLER_YAML="${2:?}"; shift 2;; --moveit-yaml) MOVEIT_YAML="${2:?}"; shift 2;; -h|--help) echo '用法：check_joint_name_consistency.sh [--urdf FILE] [--controller-yaml FILE] [--moveit-yaml FILE]'; exit 0;; *) echo "未知参数：$1" >&2; exit 2;; esac; done
extract_urdf(){ grep -oE '<joint[^>]+name="[^"]+"' "$1" | sed -E 's/.*name="([^"]+)"/\1/' | sort -u; }
extract_yaml(){ grep -E '^[[:space:]]*-[[:space:]]*[A-Za-z0-9_]+' "$1" | sed -E 's/^[[:space:]]*-[[:space:]]*//' | sort -u; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
[[ -f "$URDF" ]] && extract_urdf "$URDF" > "$TMP/urdf"
[[ -f "$CONTROLLER_YAML" ]] && extract_yaml "$CONTROLLER_YAML" > "$TMP/controller"
[[ -f "$MOVEIT_YAML" ]] && extract_yaml "$MOVEIT_YAML" > "$TMP/moveit"
for f in "$TMP"/*; do [[ -e "$f" ]] && { echo "== $(basename "$f") =="; cat "$f"; }; done
[[ -f "$TMP/urdf" && -f "$TMP/controller" ]] && { echo '== URDF vs controller =='; diff -u "$TMP/urdf" "$TMP/controller" || true; }
