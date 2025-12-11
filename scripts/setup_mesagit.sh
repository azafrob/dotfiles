#!/bin/sh

cd && rm -rf mesa-git-local/
yay -G mesa-git
cd mesa-git
makepkg -so
cd ./src/mesa
meson setup build64 --libdir lib64 --prefix $HOME/mesa-git-local -Dgallium-drivers=radeonsi,zink,svga,softpipe,llvmpipe -Dvulkan-drivers=amd -Dbuildtype=release
meson install -C build64
cd && rm -rf mesa-git/
sudo cp -rf ~/dotfiles/scripts/run-mesa-git /usr/bin/run-mesa-git
