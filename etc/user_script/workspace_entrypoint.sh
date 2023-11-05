#!/usr/bin/env bash

set -e

source "/opt/ros/$ROS_DISTRO/setup.bash" --
if [ -f "/root/work/install/setup.bash" ]; then
    source "/root/work/install/setup.bash" --
fi
exec "$@"
