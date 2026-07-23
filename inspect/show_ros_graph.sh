#!/usr/bin/env bash
set -Eeuo pipefail
source "/opt/ros/${ROS_DISTRO:-jazzy}/setup.bash"
exec rqt_graph "$@"
