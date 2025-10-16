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
  cachyos-settings
  scx-scheds-git
  limine-mkinitcpio-hook
  limine-snapper-sync
  xdg-desktop-portal-gtk
  stow
  yazi
  fuse2
  downgrade
  easyeffects
  flatpak
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra
  amdgpu_top
  rocm-smi-lib
  ethtool
  lizardbyte-beta/sunshine-git
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
  org.qbittorrent.qBittorrent
  org.jdownloader.JDownloader
  com.vysp3r.ProtonPlus
  dev.vencord.Vesktop
  com.github.tchx84.Flatseal
  io.github.lawstorant.boxflat
)

echo "=== Creating directories and files ==="
sudo touch /etc/default/limine

echo "=== Copying config files if they do not exist ==="
[[ ! -f /etc/original_pacman.conf ]] && sudo cp /etc/pacman.conf /etc/original_pacman.conf

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

echo "=== Importing pacman keys ==="
sudo pacman-key --init
sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key F3B607488DB35A47

echo "=== Installing repo keyrings and mirrorlists ==="
sudo pacman -U --noconfirm \
  https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst \
  https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-22-1-any.pkg.tar.zst \
  https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-22-1-any.pkg.tar.zst \
  https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-22-1-any.pkg.tar.zst \
  https://mirror.cachyos.org/repo/x86_64/cachyos/pacman-7.0.0.r7.g1f38429-1-x86_64.pkg.tar.zst

echo "=== Adding repositories to /etc/pacman.conf ==="
sudo tee /tmp/pacman.conf.tmp >/dev/null <<EOF
[cachyos-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos-core-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos-extra-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist

[lizardbyte]
SigLevel = Optional
Server = https://github.com/LizardByte/pacman-repo/releases/latest/download

[lizardbyte-beta]
SigLevel = Optional
Server = https://github.com/LizardByte/pacman-repo/releases/download/beta
EOF

cat /tmp/pacman.conf.tmp /etc/original_pacman.conf >/tmp/pacman.conf.new && sudo mv /tmp/pacman.conf.new /etc/pacman.conf
sudo rm /tmp/pacman.conf.tmp

echo "=== Updating system ==="
sudo pacman -Syu --noconfirm

echo "=== Installing packages ==="
sudo pacman -S --noconfirm --needed "${ARCH_PACKAGES[@]}"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"

echo "=== Setting up Flatpak ==="
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y "${FLATPAK_PACKAGES[@]}"

echo "=== Enabling/disabling services ==="
sudo systemctl enable limine-snapper-sync
sudo systemctl disable scx
sudo systemctl enable scx_loader
sudo systemctl enable lactd
sudo systemctl enable fan2go
sudo systemctl enable power-profiles-daemon
sudo systemctl enable pci-latency
sudo systemctl disable ananicy-cpp
sudo systemctl enable wol@enp9s0.service # Caution interface name (enp9s0) might change

echo "=== Removing files before stowing ==="
rm "$HOME/.config/hypr/autostart.conf"
rm "$HOME/.config/hypr/envs.conf"
rm "$HOME/.config/hypr/monitors.conf"
rm "$HOME/.config/hypr/bindings.conf"

echo "=== Running stow for user config ==="
stow -t "$HOME" -d "$HOME/dotfiles" omarchy
stow -t "$HOME" -d "$HOME/dotfiles" mangohud
stow -t "$HOME" -d "$HOME/dotfiles" SLSsteam
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
