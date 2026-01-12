#!/bin/sh

MESA="$HOME/mesa-git-local" \
LD_LIBRARY_PATH="$MESA/lib64" \
VK_DRIVER_FILES="$MESA/share/vulkan/icd.d/radeon_icd.x86_64.json" \
exec "$@"
