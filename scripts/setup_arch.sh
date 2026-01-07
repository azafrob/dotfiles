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
papirus-icon-theme
pavucontrol
peazip
power-profiles-daemon
protonplus
protontricks
python-pywalfox
qt6ct-kde
rocm-smi-lib
rsync
scx-scheds
scx-tools
spicetify-cli
spotify
steam
stow
sunshine
terminus-font
tldr
tree
tree-sitter-cli
ufw
wezterm-git
wlsunset
xdg-desktop-portal-gtk
xdotool
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
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
cd
rm -rf /tmp/yay

yay -Syu --needed --noconfirm "${ARCH_PACKAGES[@]}"

flatpak install --or-update -y "${FLATPAK_PACKAGES[@]}"

curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash

curl -L -o SLSsteam.tar.gz https://github.com/AceSLS/SLSsteam/releases/latest/download/SLSsteam-Arch.pkg.tar.zst
sudo pacman -U --noconfirm SLSsteam.tar.gz
rm SLSsteam.tar.gz

fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher install IlanCosman/tide@v6"

sh -c "$(curl -sS https://vencord.dev/install.sh)"

curl -fsSL https://opencode.ai/install | bash

echo "=== Tweaking settings ==="
sudo tee /etc/mkinitcpio.conf.d/custom.conf >/dev/null <<EOF
MODULES=(nct6775 ntsync i2c-dev)
EOF

# Auto-detect first wired connection for Wake-on-LAN
NET_CONN=$(nmcli -t -f NAME,TYPE connection show | grep 'ethernet' | head -n1 | cut -d: -f1)
if [ -n "$NET_CONN" ]; then
    nmcli c modify "$NET_CONN" 802-3-ethernet.wake-on-lan magic
else
    echo "Warning: No wired network connection found, skipping Wake-on-LAN setup"
fi

echo 'KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c31c", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/69-remapper.rules

chsh -s /usr/bin/fish

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

rm $HOME/.config/kwalletrc
echo -e "[Wallet]\nEnabled=false" >> ~/.config/kwalletrc

tee $HOME/.local/bin/custom-trigger >/dev/null <<EOF
#!/bin/bash

(exec -a CUSTOM_TRIGGER tail -f /dev/null) &
TRIGGER_PID=\$!
"\$@" &
MASTER_PID=\$!
cleanup() {
kill \$TRIGGER_PID 2>/dev/null
}
trap cleanup EXIT
wait \$MASTER_PID
EOF

chmod +x $HOME/.local/bin/custom-trigger

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
sudo systemctl enable scx_loader lactd fan2go

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

sudo ufw --force enable

echo "=== Backing up existing configs ==="
if [ -f "$HOME/.config/hypr/hyprland.conf" ] && [ ! -L "$HOME/.config/hypr/hyprland.conf" ]; then
	timestamp=$(date +%Y%m%d_%H%M%S)
	mv "$HOME/.config/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf.backup.$timestamp"
	echo "Backed up hyprland.conf to hyprland.conf.backup.$timestamp"
fi

echo "=== Running stow for user config ==="
stow --no-folding -t "$HOME" -d "$HOME/dotfiles" hypr mangohud sunshine frogminer btop micro noctalia menus qt6ct yazi bat fish nvim wezterm xdg

sudo stow --no-folding -t / -d "$HOME/dotfiles" fan2go scx_loader ly

echo "=== Running user commands ==="
tldr --update
ln --symbolic "$HOME/.steam/steam/steamapps/common/" "$HOME/Games"

echo "=== Running system commands ==="
sudo limine-mkinitcpio

echo "=== Done! ==="
read -p "Would you like to reboot now? (y/n): " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    sudo reboot
fi
