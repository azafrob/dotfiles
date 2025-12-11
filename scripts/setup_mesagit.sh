#!/bin/sh

cd && rm -rf mesa/ mesa-git/ && git clone https://gitlab.freedesktop.org/mesa/mesa
cd mesa/
meson setup build64 --libdir lib64 --prefix $HOME/mesa-git -Dgallium-drivers=radeonsi,zink,svga,softpipe,llvmpipe -Dvulkan-drivers=amd -Dbuildtype=release
meson install -C build64
cd && rm -rf mesa/
sudo cp -rf ~/dotfiles/scripts/run-mesa-git /usr/bin/run-mesa-git
