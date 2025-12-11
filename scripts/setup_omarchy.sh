#!/bin/sh

set -euo pipefail

# === Safety check: Don't run as root ===
if [[ $EUID -eq 0 ]]; then
  echo "Error: Don't run this script as root!"
  exit 1
fi

# Variables
ARCH_PACKAGES=(
  linux-cachyos
  linux-cachyos-headers
  scx-scheds
  scx-tools
  stow
  steam
  yazi
  flatpak
  amdgpu_top
  rocm-smi-lib
  ethtool
  gamescope
  mangohud
  lib32-mangohud
  lact
  easyeffects
  vulkan-radeon
  lib32-vulkan-radeon
)

AUR_PACKAGES=(
  fan2go-git
  sunshine
  downgrade
  bibata-cursor-theme
  journalctl-desktop-notification
)

FLATPAK_PACKAGES=(
  org.qbittorrent.qBittorrent
  org.jdownloader.JDownloader
  com.vysp3r.ProtonPlus
  dev.vencord.Vesktop
  com.github.tchx84.Flatseal
  io.github.lawstorant.boxflat
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
sudo pacman -S --noconfirm --needed "${ARCH_PACKAGES[@]}"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"

echo "=== Setting up Flatpak ==="
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y "${FLATPAK_PACKAGES[@]}"

echo "=== Tweaking settings ==="
sudo tee /etc/mkinitcpio.conf.d/custom.conf >/dev/null <<EOF
MODULES=(nct6775)
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

sed -i '0,/font-size: 12px;/s//font-size: 14px;/' ~/.config/waybar/style.css
sed -i '0,/font-size = 9/s//font-size = 10/' ~/.config/ghostty/config

sudo sed -i 's/BOOT_ORDER="\*, \*fallback, Snapshots"/BOOT_ORDER="*cachyos, *, *fallback, Snapshots"/' /etc/default/limine

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
stow -t "$HOME" -d "$HOME/dotfiles" pipewire
stow -t "$HOME" -d "$HOME/dotfiles" wireplumber

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
