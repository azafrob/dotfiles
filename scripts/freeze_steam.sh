#!/bin/bash

src="$HOME/dotfiles/res/steam.cfg"
dst="$HOME/.steam/steam/steam.cfg"

[ -f "$src" ] || { echo "Error: $src not found"; exit 1; }

if [ -f "$dst" ]; then
    echo "Removing existing: $dst"
    rm -f "$dst"
else
    echo "No existing file found"
    echo "Copying $src → $dst"
    cp "$src" "$dst" && echo "Done" || echo "Copy failed"
fi
