#!/bin/bash

MESA_PATH="$HOME/mesa-git-local/usr"
export LD_LIBRARY_PATH="$MESA_PATH/lib:$MESA_PATH/lib32:$LD_LIBRARY_PATH"
export LIBGL_DRIVERS_PATH="$MESA_PATH/lib/dri:$MESA_PATH/lib32/dri"
export VK_ICD_FILENAMES="$MESA_PATH/share/vulkan/icd.d/radeon_icd.x86_64.json:$MESA_PATH/lib32/share/vulkan/icd.d/radeon_icd.i686.json"

exec "$@"
