#!/bin/sh

sudo -v

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Error: Don't run this script as root!"
  exit 1
fi

cd && rm -rf mesa-git/ mesa-git-local/
git clone https://github.com/Frogging-Family/mesa-git.git
cd mesa-git
makepkg -so
cd src/mesa
meson setup build64 --libdir lib64 --prefix $HOME/mesa-git-local -Dgallium-drivers=radeonsi,zink,svga,softpipe,llvmpipe -Dvulkan-drivers=amd,swrast -Dbuildtype=release -Dvideo-codecs=all
meson install -C build64
cd && rm -rf mesa-git/

tee $HOME/.local/bin/run-mesa-git >/dev/null <<EOF
#!/bin/sh

MESA="\$HOME/mesa-git-local" \\
LD_LIBRARY_PATH="\$MESA/lib64" \\
VK_DRIVER_FILES="\$MESA/share/vulkan/icd.d/radeon_icd.x86_64.json" \\
exec "\$@"
EOF

chmod +x $HOME/.local/bin/run-mesa-git
