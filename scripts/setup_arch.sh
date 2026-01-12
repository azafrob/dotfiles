#!/bin/bash

sudo -v

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
	echo "Error: Don't run this script as root!"
	exit 1
fi

ARCH_PACKAGES=(
adw-gtk-theme
amdgpu_top
aria2
atool
bambustudio-bin
base-devel
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
edk2-ovmf
fan2go-git
fastfetch
fd
feh
fish
flatpak
fuse2
fzf
gamescope
hyprpolkitagent
journalctl-desktop-notification
jq
kvantum
lact
lazygit
less
limine-mkinitcpio-hook
limine-snapper-sync
libvirt
linux
linux-headers
linux-zen
linux-zen-headers
localsend
luarocks
ludusavi
man-db
mangohud
matugen
micro
mpv
neovim
noctalia-shell
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
nushell
nwg-look
okular
onlyoffice-bin
opencode-bin
papirus-icon-theme
pavucontrol
peazip
power-profiles-daemon
protonplus
protontricks
qt6ct-kde
qemu-desktop
rocm-smi-lib
rsync
scx-scheds
scx-tools
spicetify-cli
spotify
steam
stow
sunshine
swtpm
terminus-font
tldr
tree
tree-sitter-cli
ufw
wezterm-git
virt-manager
wlsunset
xdg-desktop-portal-gtk
xdotool
virtio-win
xorg-xwininfo
yad
yazi
zen-browser-bin
zenergy-dkms-git
zoxide
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

flatpak install --or-update -y "${FLATPAK_PACKAGES[@]}"

echo "=== Tweaking settings ==="
sudo tee /etc/mkinitcpio.conf.d/custom.conf >/dev/null <<EOF
MODULES=(nct6775 ntsync i2c-dev)
EOF

NET_CONN=$(nmcli -t -f NAME,TYPE connection show | grep 'ethernet' | head -n1 | cut -d: -f1)
if [ -n "$NET_CONN" ]; then
    nmcli c modify "$NET_CONN" 802-3-ethernet.wake-on-lan magic
else
    echo "Warning: No wired network connection found, skipping Wake-on-LAN setup"
fi

echo 'KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c31c", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/69-remapper.rules

chsh -s /usr/bin/fish

sudo usermod -aG libvirt "$USER"

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

rm $HOME/.config/kwalletrc
echo -e "[Wallet]\nEnabled=false" >> ~/.config/kwalletrc

sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R
spicetify backup apply

sudo setcap cap_sys_admin+p $(readlink -f $(which sunshine))

if grep -q "^FONT=" /etc/vconsole.conf; then
	sudo sed -i "s/^FONT=.*/FONT=ter-v32n/" /etc/vconsole.conf
else
	sudo sh -c 'echo "FONT=ter-v32n" >> /etc/vconsole.conf'
fi

echo "=== Enabling/disabling services ==="
sudo systemctl enable ufw scx_loader lactd fan2go libvirtd virtlogd

echo "=== Configuring UFW firewall ==="
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 47984/tcp comment 'Sunshine'
sudo ufw allow 47989/tcp comment 'Sunshine'
sudo ufw allow 47990/tcp comment 'Sunshine web UI'
sudo ufw allow 48010/tcp comment 'Sunshine'
sudo ufw allow 47998/udp comment 'Sunshine'
sudo ufw allow 47999/udp comment 'Sunshine'
sudo ufw allow 48000/udp comment 'Sunshine'
sudo ufw allow 5900:5910/tcp comment 'VM console (Spice/VNC)'

sudo ufw --force enable

echo "=== Configuring libvirt network ==="
if [ -f /etc/libvirt/qemu/networks/default.xml ]; then
	if ! virsh net-list --all | grep -q "default"; then
		sudo virsh net-define /etc/libvirt/qemu/networks/default.xml
		echo "Defined default libvirt network"
	fi
	
	if ! virsh net-list | grep -q "default.*active"; then
		sudo virsh net-start default
		echo "Started default libvirt network"
	fi
	
	if ! virsh net-list --name | grep -q "default"; then
		sudo virsh net-autostart default
		echo "Set default libvirt network to autostart"
	fi
else
	echo "Warning: Default network XML not found, may need manual setup"
fi

echo "=== Backing up existing configs ==="
if [ -f "$HOME/.config/hypr/hyprland.conf" ] && [ ! -L "$HOME/.config/hypr/hyprland.conf" ]; then
	mv "$HOME/.config/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf.bak"
fi

echo "=== Running stow for user config ==="
stow --no-folding -t "$HOME" -d "$HOME/dotfiles" hypr mangohud sunshine frogminer btop micro noctalia menus qt6ct yazi bat fish nvim wezterm xdg mpv

sudo stow --no-folding -t / -d "$HOME/dotfiles" fan2go scx_loader

echo "=== Running user commands ==="
tldr --update
ln --symbolic "$HOME/.steam/steam/steamapps/common/" "$HOME/Games"

echo "=== Running system commands ==="
sudo limine-mkinitcpio

echo "=== Post-setup ==="
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher install IlanCosman/tide@v6"

sh -c "$(curl -sS https://vencord.dev/install.sh)"

curl -L -o SLSsteam.tar.gz https://github.com/AceSLS/SLSsteam/releases/latest/download/SLSsteam-Arch.pkg.tar.zst
sudo pacman -U --noconfirm SLSsteam.tar.gz
rm SLSsteam.tar.gz

yay -S informant

read -p "Would you like to reboot now? (y/n): " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
	sudo reboot
fi
