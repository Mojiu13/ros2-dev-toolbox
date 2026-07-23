#!/usr/bin/env bash
set -Eeuo pipefail
ROS_DISTRO_VALUE="${ROS_DISTRO:-jazzy}"
source "/opt/ros/${ROS_DISTRO_VALUE}/setup.bash"
required=(moveit_ros_move_group moveit_ros_planning_interface moveit_configs_utils)
missing=0
for pkg in "${required[@]}" "$@"; do
  if ros2 pkg prefix "$pkg" >/dev/null 2>&1; then echo "present: $pkg"; else echo "missing: $pkg"; missing=1; fi
done
python3 - <<'PY' || true
try:
    import moveit
    print('python: moveit available')
except Exception as exc:
    print(f'python: moveit unavailable ({exc})')
PY
exit "$missing"
