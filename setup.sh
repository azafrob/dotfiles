#!/bin/bash

curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh

sudo pacman -Syu

sudo pacman -S linux-cachyos linux-cachyos-headers cachyos-settings scx-scheds-git mesa-git mesa-utils yay power-profiles-daemon

sudo pacman -S git zsh ghostty pulsemixer pamixer pavucontrol man-db tealdeer stow neovim downgrade bat fzf zoxide eza ripgrep fd fastfetch

sudo pacman -S nwg-look kvantum waybar rofi-wayland hyprpaper libnotify qt5ct qt6ct qt5-wayland qt6-wayland

sudo pacman -S nerd-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-liberation ttf-dejavu ttf-roboto

yay -S ttf-symbola

sudo pacman -S snapper limine-snapper-sync limine-mkinitcpio-hook

sudo pacman -S firefox mangohud btop rocm-smi-lib

sudo pacman -S cachyos-gaming-meta

systemctl disable --now ananicy-cpp
