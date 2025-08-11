#!/usr/bin/env bash

set -euo pipefail
set -x # Show each command before running

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
  downgrade
  flatpak
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra
  amdgpu_top
  rocm-smi-lib
  firefox
  lizardbyte-beta/sunshine-git
)

AUR_PACKAGES=(
  fan2go-git
  lact-git
  bibata-cursor-theme
  mangohud-git
  lib32-mangohud-git
  journalctl-desktop-notification
  arkenfox-user.js
  informant
)

FLATPAK_PACKAGES=(
  org.qbittorrent.qBittorrent
  org.jdownloader.JDownloader
  com.github.Matoking.protontricks
  com.vysp3r.ProtonPlus
  dev.vencord.Vesktop
  com.github.tchx84.Flatseal
  it.mijorus.gearlever
)

echo "=== Creating directories and files ==="
sudo mkdir -p /usr/lib/firmware/edid/
sudo touch /etc/default/limine

echo "=== Copying config files if they do not exist ==="
[[ ! -f /usr/lib/firmware/edid/modified-edid ]] && sudo cp "$HOME/dotfiles/res/modified-edid" /usr/lib/firmware/edid/modified-edid
[[ ! -f /etc/original_cmdline ]] && sudo cp /proc/cmdline /etc/original_cmdline

echo "=== Writing blockinfile content ==="
sudo tee /etc/mkinitcpio.conf.d/custom.conf >/dev/null <<EOF
FILES=(/usr/lib/firmware/edid/modified-edid)
MODULES=(nct6775)
EOF

sudo tee /etc/default/limine >/dev/null <<EOF
KERNEL_CMDLINE["linux-cachyos"]="$(cat /etc/original_cmdline) drm.edid_firmware=HDMI-A-1:edid/modified-edid video=HDMI-A-1:e"
BOOT_ORDER="*cachyos, *zen, *, *fallback, Snapshots"
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
sudo tee -a /etc/pacman.conf >/dev/null <<EOF
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

echo "=== Updating system ==="
sudo pacman -Syu --noconfirm

echo "=== Installing packages ==="
sudo pacman -S --noconfirm "${ARCH_PACKAGES[@]}"
yay -S --noconfirm "${AUR_PACKAGES[@]}"

echo "=== Setting up Flatpak ==="
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y "${FLATPAK_PACKAGES[@]}"

echo "=== Enabling/disabling services ==="
sudo systemctl enable limine-snapper-sync
sudo systemctl disable scx
sudo systemctl enable scx_loader
sudo systemctl enable lactd
sudo systemctl enable fan2go
sudo systemctl disable ananicy-cpp

echo "=== Running stow for user config ==="
stow -t "$HOME" -d "$HOME/dotfiles" omarchy
stow -t "$HOME" -d "$HOME/dotfiles" mangohud
stow -t "$HOME" -d "$HOME/dotfiles" SLSsteam
stow -t "$HOME" -d "$HOME/dotfiles" sunshine

echo "=== Running stow for system config ==="
sudo stow -t / -d "$HOME/dotfiles" fan2go
sudo stow -t / -d "$HOME/dotfiles" scx_loader

echo "=== Running user commands ==="
tldr --update
nmcli c modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic

echo "=== Running system commands ==="
sudo limine-mkinitcpio

echo "=== Done! ==="
