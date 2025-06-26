#!/bin/bash

curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh

sudo pacman -Syu

sudo pacman -S linux-cachyos linux-cachyos-headers cachyos-settings scx-scheds-git mesa-git mesa-utils yay power-profiles-daemon limine-entry-tool xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

sudo pacman -S git fish ghostty man-db tealdeer stow neovim downgrade bat fzf zoxide eza ripgrep fd fastfetch atool flatpak timeshift yazi

sudo pacman -S nwg-look kvantum waybar hyprpaper dunst wofi libnotify qt6ct catppuccin-gtk-theme-mocha

sudo pacman -S nerd-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra

sudo pacman -S firefox mangohud btop rocm-smi-lib

sudo pacman -S cachyos-gaming-meta cachyos-gaming-applications gamemode

yay -S fan2go-git lact-git

systemctl disable --now ananicy-cpp

systemctl disable --now scx.service && systemctl enable --now scx_loader.service

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

tldr --update

git clone https://github.com/catppuccin/Kvantum.git
