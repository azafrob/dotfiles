#!/bin/bash

sudo -v

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
	echo "Error: Don't run this script as root!"
	exit 1
fi

HYPRLAND_PACKAGES=(
adw-gtk-theme
hyprpolkitagent
journalctl-desktop-notification
noctalia-shell
nwg-look
qt6ct-kde
wlsunset
xdg-desktop-portal-gtk
xdg-desktop-portal-hyprland
)

ARCH_PACKAGES=(
amdgpu_top
atool
atuin
bat
bibata-cursor-theme
boxflat-git
btop
calibre
cava
cliphist
ddcutil
discord
downgrade
easyeffects
eza
fan2go-git
fastfetch
fd
feh
flatpak
fuse2
fzf
gamescope
getnf
jq
lact
lazygit
less
linux-zen
linux-zen-headers
limine-mkinitcpio-hook
limine-snapper-sync
localsend
luarocks
ludusavi
man-db
mangohud
mpv
neovim
okular
papirus-icon-theme
peazip
power-profiles-daemon
protonplus
protontricks
rclone
rocm-smi-lib
rsync
scx-scheds
scx-tools
spicetify-cli
spotify
steam
stow
sunshine
tldr
trash-cli
tree
tree-sitter-cli
ufw
veracrypt
wezterm
wgcf
yad
yazi
zen-browser-bin
zenergy-dkms-git
zoxide
zsh
)

FLATPAK_PACKAGES=(
com.github.tchx84.Flatseal
it.mijorus.gearlever
)

echo "=== Adding Chaotic-AUR repo ==="
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
	echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

echo "=== Installing packages ==="
sudo pacman -S --needed git base-devel reflector
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
cd
rm -rf /tmp/yay

sudo reflector --latest 20 --fastest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist

yay -Syu --needed --noconfirm "${ARCH_PACKAGES[@]}"
yay -Syu --needed --noconfirm "${HYPRLAND_PACKAGES[@]}"

flatpak install --or-update -y "${FLATPAK_PACKAGES[@]}"

echo "=== Tweaking settings ==="
sudo tee /etc/mkinitcpio.conf.d/custom.conf >/dev/null <<EOF
MODULES=(nct6775 i2c-dev)
EOF

NET_CONN=$(nmcli -t -f NAME,TYPE connection show | grep 'ethernet' | head -n1 | cut -d: -f1)
if [ -n "$NET_CONN" ]; then
    nmcli c modify "$NET_CONN" 802-3-ethernet.wake-on-lan magic
else
    echo "Warning: No wired network connection found, skipping Wake-on-LAN setup"
fi

echo 'KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c31c", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/69-remapper.rules

chsh -s /usr/bin/zsh

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

rm "$HOME/.config/kwalletrc"
echo -e "[Wallet]\nEnabled=false" >> ~/.config/kwalletrc

sudo setcap cap_sys_admin+p $(readlink -f $(which sunshine))

if grep -q "^FONT=" /etc/vconsole.conf; then
	sudo sed -i "s/^FONT=.*/FONT=ter-v32n/" /etc/vconsole.conf
else
	sudo sh -c 'echo "FONT=ter-v32n" >> /etc/vconsole.conf'
fi

echo "=== Enabling/disabling services ==="
sudo systemctl enable ufw scx_loader lactd fan2go

echo "=== Configuring UFW firewall ==="
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 47984/tcp comment 'Sunshine'
sudo ufw allow 47989/tcp comment 'Sunshine'
sudo ufw allow 47990/tcp comment 'Sunshine'
sudo ufw allow 48010/tcp comment 'Sunshine'
sudo ufw allow 47998/udp comment 'Sunshine'
sudo ufw allow 47999/udp comment 'Sunshine'
sudo ufw allow 48000/udp comment 'Sunshine'
sudo ufw allow 53317 comment 'LocalSend'

sudo ufw --force enable

echo "=== Backing up existing configs ==="
if [ -f "$HOME/.config/hypr/hyprland.conf" ] && [ ! -L "$HOME/.config/hypr/hyprland.conf" ]; then
	mv "$HOME/.config/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf.bak"
fi

echo "=== Running stow for user config ==="
stow --no-folding -t "$HOME" -d "$HOME/dotfiles" mangohud sunshine frogminer btop yazi bat zsh nvim wezterm mpv
stow --no-folding -t "$HOME" -d "$HOME/dotfiles" hypr qt6ct menus noctalia xdg

sudo stow --no-folding -t / -d "$HOME/dotfiles" fan2go scx_loader

echo "=== Running user commands ==="
tldr --update
ln --symbolic "$HOME/.steam/steam/steamapps/common/" "$HOME/Games"

echo "=== Running system commands ==="
sudo limine-mkinitcpio

echo "=== Post-setup ==="
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep

sh -c "$(curl -sS https://vencord.dev/install.sh)"

sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R
spicetify backup apply

yay -S informant

read -rp "Would you like to reboot now? (y/n): " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
	sudo reboot
fi
