#!/bin/bash

curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh

echo -e "[lizardbyte-beta]\nSigLevel = Optional\nServer = https://github.com/LizardByte/pacman-repo/releases/download/beta" | sudo tee -a /etc/pacman.conf

sudo pacman -Syu

sudo pacman -S linux-cachyos linux-cachyos-headers cachyos-settings scx-scheds-git mesa-git mesa-utils yay power-profiles-daemon limine-entry-tool xdg-desktop-portal-hyprland xdg-desktop-portal-gtk cachyos-rate-mirrors

sudo pacman -S git fish ghostty man-db tealdeer stow neovim downgrade bat fzf zoxide eza ripgrep fd fastfetch atool flatpak timeshift yazi brightnessctl

sudo pacman -S nwg-look kvantum waybar hyprpaper dunst wofi libnotify qt6ct hyprlock hypridle

sudo pacman -S nerd-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra

sudo pacman -S firefox mangohud btop rocm-smi-lib thunar papirus-icon-theme

sudo pacman -S cachyos-gaming-meta cachyos-gaming-applications gamemode

sudo pacman -S lizardbyte-beta/sunshine-git

yay -S fan2go-git lact-git bibata-cursor-theme catppuccin-gtk-theme-mocha

yay -S zenergy-dkms-git

echo "options amdgpu ppfeaturemask=0xFFF7FFFF" | sudo tee /etc/modprobe.d/99-amdgpu-overdrive.conf"

echo "nct6775" | sudo tee /etc/modules-load.d/custom_modules.conf

echo -e 'default_sched = "scx_lavd"\ndefault_mode = "Auto"' | sudo tee /etc/scx_loader.toml

systemctl disable --now ananicy-cpp

systemctl disable --now scx.service && systemctl enable --now scx_loader.service

sudo systemctl enable --now lactd

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

tldr --update

bat cache --build

sudo limine-entry-tool --scan
