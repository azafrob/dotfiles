#!/bin/sh

sudo -v

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "Error: Don't run this script as root!"
  exit 1
fi

# Variables
ARCH_PACKAGES=(
  #zram-generator
  amd-ucode
  amdgpu_top
  aria2
  atool
  bambustudio-bin
  base
  base-devel
  bat
  bibata-cursor-theme
  boxflat-git
  brave-bin
  btop
  calibre
  curl
  ddcutil
  discord
  downgrade
  easyeffects
  ethtool
  eza
  fan2go-git
  fastfetch
  fd
  fish
  flatpak
  fontconfig
  fuse2
  fuse3
  fzf
  gamescope
  git
  journalctl-desktop-notification
  jq
  kvantum
  lact
  layzgit
  less
  lib32-mangohud
  lib32-vulkan-radeon
  limine
  limine-mkinitcpio-hook
  limine-snapper-sync
  localsend
  luarocks
  ludusavi
  man-db
  mangohud
  micro
  mpv
  neovim
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra
  nwg-look
  protonplus
  protontricks
  qt5ct
  qt6ct
  ripgrep
  rocm-smi-lib
  rsync
  scx-scheds
  scx-tools
  snapper
  spotify
  steam
  stow
  sunshine
  tldr
  ufw
  uwsm
  vulkan-radeon
  wget
  xdg-desktop-portal-hyprland
  yazi
  zoxide
)

FLATPAK_PACKAGES=(
  com.github.tchx84.Flatseal
)

echo "=== Adding Chaotic-AUR repo ==="
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

echo "=== Updating system ==="
sudo pacman -Syu --noconfirm

echo "=== Installing packages ==="
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
cd
rm -rf /tmp/yay
yay -S --needed --noconfirm "${ARCH_PACKAGES[@]}"
flatpak install -y "${FLATPAK_PACKAGES[@]}"
curl -L -o SLSsteam.tar.gz https://github.com/AceSLS/SLSsteam/releases/latest/download/SLSsteam-Arch.pkg.tar.zst
sudo pacman -U --noconfirm SLSsteam.tar.gz
rm SLSsteam.tar.gz

echo "=== Tweaking settings ==="
sudo tee /etc/mkinitcpio.conf.d/custom.conf >/dev/null <<EOF
MODULES=(nct6775 ntsync i2c-dev)
EOF

sudo tee /etc/systemd/system/wol@.service >/dev/null <<EOF
[Unit]
Description=Wake-on-LAN for %i
Requires=network.target
After=network.target

[Service]
ExecStart=/usr/bin/ethtool -s %i wol g
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

echo 'KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c31c", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/69-remapper.rules

tee $HOME/.local/bin/custom-trigger >/dev/null <<EOF
#!/bin/sh

(exec -a CUSTOM_TRIGGER tail -f /dev/null) &
TRIGGER_PID=\$!
"\$@" &
MASTER_PID=\$!
cleanup() {
    kill \$TRIGGER_PID 2>/dev/null
}
trap cleanup EXIT
wait \$MASTER_PID
EOF

chmod +x $HOME/.local/bin/custom-trigger

sudo setcap cap_sys_admin+p $(readlink -f $(which sunshine))

echo "=== Enabling/disabling services ==="
sudo systemctl enable scx_loader
sudo systemctl enable lactd
sudo systemctl enable fan2go
sudo systemctl enable wol@enp9s0.service # Caution interface name (enp9s0) might change [ip link show]

echo "=== Removing files before stowing ==="
rm "$HOME/.config/hypr/autostart.conf" || true
rm "$HOME/.config/hypr/envs.conf" || true
rm "$HOME/.config/hypr/monitors.conf" || true
rm "$HOME/.config/sunshine/sunshine.conf" || true

echo "=== Running stow for user config ==="
stow -t "$HOME" -d "$HOME/dotfiles" hypr
stow -t "$HOME" -d "$HOME/dotfiles" mangohud
stow -t "$HOME" -d "$HOME/dotfiles" sunshine
stow -t "$HOME" -d "$HOME/dotfiles" frogminer

if ! grep -q "~/.config/hypr/envs.conf" ~/.config/hypr/hyprland.conf; then
  echo "source = ~/.config/hypr/envs.conf" >> ~/.config/hypr/hyprland.conf
fi

echo "=== Running stow for system config ==="
sudo stow -t / -d "$HOME/dotfiles" fan2go
sudo stow -t / -d "$HOME/dotfiles" scx_loader

echo "=== Running user commands ==="
tldr --update
ln --symbolic "$HOME/.steam/steam/steamapps/common/" "$HOME/Games"

echo "=== Running system commands ==="
sudo limine-mkinitcpio

echo "=== Done! ==="
