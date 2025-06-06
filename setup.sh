#!/bin/bash

curl https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz && cd cachyos-repo
sudo ./cachyos-repo.sh

sudo pacman -Syu

sudo pacman -S linux-cachyos cachyos-settings scx-scheds-git mesa-git mesa-utils

sudo pacman -S git fish foot pulsemixer pamixer pavucontrol man-db tealdeer stow neovim downgrade

sudo pacman -S nwg-look kvantum waybar rofi-wayland hyprpaper libnotify qt5ct qt6ct qt5-wayland qt6-wayland

sudo pacman -S nerd-fonts

sudo pacman -S snapper limine-snapper-sync limine-mkinitcpio-hook

sudo pacman -S brave vesktop

sudo pacman -S cachyos-gaming-meta

sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd .. && rm -rf paru
