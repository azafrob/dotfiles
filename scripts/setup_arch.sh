#!/bin/bash

sudo -v

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
	echo "Error: Don't run this script as root!"
	exit 1
fi

# Variables
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
layzgit
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

echo "=== Updating system ==="
sudo pacman -Syu --noconfirm

echo "=== Installing packages ==="
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
cd
rm -rf /tmp/yay

yay -S --needed --noconfirm "${ARCH_PACKAGES[@]}"

flatpak install --or-update -y "${FLATPAK_PACKAGES[@]}"

curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
getnf -i JetBrainsMono

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

nmcli c modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic

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
	sed -i "s/^FONT=.*/FONT=ter-v32n/" /etc/vconsole.conf
else
	echo "FONT=ter-v32n" >> /etc/vconsole.conf;
fi

echo "=== Enabling/disabling services ==="
sudo systemctl enable scx_loader lactd fan2go

echo "=== Running stow for user config ==="
stow --no-folding -t "$HOME" -d "$HOME/dotfiles" hypr mangohud sunshine frogminer btop micro noctalia menus qt6ct

echo "=== Running stow for system config ==="
sudo stow --no-folding -t / -d "$HOME/dotfiles" fan2go scx_loader ly

echo "=== Running user commands ==="
tldr --update
ln --symbolic "$HOME/.steam/steam/steamapps/common/" "$HOME/Games"

echo "=== Running system commands ==="
sudo limine-mkinitcpio

echo "=== Done! ==="
