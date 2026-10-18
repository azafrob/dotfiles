#!/bin/bash
set -euo pipefail

MESA_SRC="$HOME/src/mesa"
MESA_INSTALLDIR="$MESA_SRC/installdir"

if [[ ! -d "$MESA_SRC/.git" ]]; then
    git clone https://gitlab.freedesktop.org/mesa/mesa.git "$MESA_SRC"
else
    git -C "$MESA_SRC" fetch origin main
    git -C "$MESA_SRC" reset --hard origin/main
fi

cd "$MESA_SRC"
rm -rf builddir installdir

meson setup builddir/ -Dprefix="$MESA_INSTALLDIR" \
    -Dgallium-drivers=radeonsi,zink \
    -Dvulkan-drivers=amd \
    -Dvideo-codecs=all \
    -Dbuildtype=release

meson install -C builddir/
