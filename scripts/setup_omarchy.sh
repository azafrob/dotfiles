#!/usr/bin/env bash

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
  scx-scheds-git
  stow
  yazi
  downgrade
  flatpak
  amdgpu_top
  rocm-smi-lib
  ethtool
  sunshine
)

AUR_PACKAGES=(
  fan2go-git
  gamescope-git
  lib32-mangohud-git
  lact-git
  bibata-cursor-theme
  mangohud-git
  journalctl-desktop-notification
)

FLATPAK_PACKAGES=(
  com.github.wwmm.easyeffects
  org.qbittorrent.qBittorrent
  org.jdownloader.JDownloader
  com.vysp3r.ProtonPlus
  dev.vencord.Vesktop
  com.github.tchx84.Flatseal
  io.github.lawstorant.boxflat
)

echo "=== Creating directories and files ==="
sudo touch /etc/default/limine

echo "=== Writing blockinfile content ==="
sudo tee /etc/mkinitcpio.conf.d/custom.conf >/dev/null <<EOF
MODULES=(nct6775)
EOF

sudo tee /etc/default/limine >/dev/null <<EOF
BOOT_ORDER="*cachyos, *, *fallback, Snapshots"
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

echo "=== Updating system ==="
sudo pacman -Syu --noconfirm

echo "=== Installing packages ==="
sudo pacman -S --noconfirm --needed "${ARCH_PACKAGES[@]}"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"

echo "=== Setting up Flatpak ==="
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y "${FLATPAK_PACKAGES[@]}"

echo "=== Enabling/disabling services ==="
sudo systemctl disable ananicy-cpp
sudo systemctl disable scx
sudo systemctl enable scx_loader
sudo systemctl enable lactd
sudo systemctl enable fan2go
sudo systemctl enable pci-latency
sudo systemctl enable wol@enp9s0.service # Caution interface name (enp9s0) might change [ip link show]

echo "=== Removing files before stowing ==="
rm "$HOME/.config/hypr/autostart.conf"
rm "$HOME/.config/hypr/envs.conf"
rm "$HOME/.config/hypr/monitors.conf"

echo "=== Running stow for user config ==="
stow -t "$HOME" -d "$HOME/dotfiles" hypr
stow -t "$HOME" -d "$HOME/dotfiles" mangohud
stow -t "$HOME" -d "$HOME/dotfiles" sunshine
stow -t "$HOME" -d "$HOME/dotfiles" pipewire
stow -t "$HOME" -d "$HOME/dotfiles" wireplumber

echo "=== Running stow for system config ==="
sudo stow -t / -d "$HOME/dotfiles" fan2go
sudo stow -t / -d "$HOME/dotfiles" scx_loader

echo "=== Running user commands ==="
tldr --update
ln --symbolic "$HOME/.steam/steam/steamapps/common/" "$HOME/Games"

echo "=== Running system commands ==="
sudo limine-mkinitcpio

echo "=== Done! ==="
