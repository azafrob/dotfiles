#!/bin/bash

# Add CachyOS repo
curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh

# Add Sunshine repo
echo -e "\n[lizardbyte-beta]\nSigLevel = Optional\nServer = https://github.com/LizardByte/pacman-repo/releases/download/beta" | sudo tee -a /etc/pacman.conf
echo -e "\n[lizardbyte]\nSigLevel = Optional\nServer = https://github.com/LizardByte/pacman-repo/releases/latest/download" | sudo tee -a /etc/pacman.conf

# Update repo
sudo pacman -Syu

# Install packages available in CachyOS repo
sudo pacman -S linux-cachyos linux-cachyos-headers cachyos-settings scx-scheds-git mesa-git mesa-utils yay power-profiles-daemon limine-entry-tool xdg-desktop-portal-hyprland xdg-desktop-portal-gtk cachyos-rate-mirrors git fish ghostty man-db tealdeer stow neovim downgrade bat fzf zoxide eza ripgrep fd fastfetch atool flatpak timeshift yazi brightnessctl nwg-look kvantum waybar hyprpaper dunst wofi libnotify qt6ct hyprlock hypridle hyprshot nerd-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra firefox btop rocm-smi-lib thunar papirus-icon-theme cachyos-gaming-meta cachyos-gaming-applications lizardbyte-beta/sunshine-git playerctl lazygit

# Install packages available in AUR repo
yay -S gamescope-git fan2go-git lact-git bibata-cursor-theme catppuccin-gtk-theme-mocha zenergy-dkms-git gamemode-git mangohud-git arkenfox-user.js

# Set AMD overdrive flag to tweak GPU
echo "options amdgpu ppfeaturemask=0xFFF7FFFF" | sudo tee "/etc/modprobe.d/99-amdgpu-overdrive.conf"

# Add actual mobo fan controller module
echo "nct6775" | sudo tee "/etc/modules-load.d/custom_modules.conf"

# Set scheduler and its options
echo -e 'default_sched = "scx_lavd"\ndefault_mode = "Auto"' | sudo tee /etc/scx_loader.toml

# Enable Wake-on-LAN
nmcli c modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic

# Disable ananicy-cpp in favor of scx
systemctl disable --now ananicy-cpp

# Disable scx service and enable scx_loader
systemctl disable --now scx.service && systemctl enable --now scx_loader.service

# Enable LACT daemon
sudo systemctl enable --now lactd

# Add flathub repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Update tldr pages
tldr --update

# Update bat settings and themes
bat cache --build

# Update arkenfox user.js
arken-updater

# Scan for other OS entries to be added
sudo limine-entry-tool --scan
