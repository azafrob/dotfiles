# Migración — lista de paquetes instalados explícitamente

Snapshot: **2026-10-18** · Origen: Arch Linux x86_64 · kernel `linux-zen` · GPU AMD (amdgpu/radeon)
Paneo: 1145 paquetes instalados → **114 explícitos** (+ 13 Flatpak, 8 AppImage, 3 binarios manuales).

Índice: [1 Pacman oficial](#1-pacman--repos-oficiales-101) ·
[2 chaotic-aur](#2-chaotic-aur-9) · [3 AUR](#3-aur--foreign-4) ·
[4 Flatpak](#4-flatpak-13) · [5 AppImage](#5-appimage-8) · [6 Otros](#6-fuera-de-pacmanflatpak-3) ·
[7 Servicios](#7-servicios-a-habilitar) · [A paso a paso](#a-reinstalación-paso-a-paso) ·
[B Apéndice: discrepancias](#b-apéndice--discrepancias-con-scriptssetup_archsh)

---

## 1. Pacman — repos oficiales (101)

### core (11)
```
amd-ucode  base  base-devel  btrfs-progs  efibootmgr  less
linux-firmware  man-db  nano  sudo  wpa_supplicant
```

### extra (89) + multilib (1)
```
amdgpu_top  atool  atuin  bat  bluez  bluez-utils  boost  btop  cliphist  cmake
compsize  dolphin  eza  fastfetch  fd  feh  fuse2  fzf  gamescope  git  github-cli
gst-plugin-pipewire  gtk-layer-shell  htop  informant  jq  konsole  krfb  lact
libpulse  limine  linux-zen  linux-zen-headers  llvm  luarocks  magic-wormhole
mangohud  meson  mpv  neovim  network-manager-applet  networkmanager  nlohmann-json
nodejs  noto-fonts  noto-fonts-cjk  noto-fonts-emoji  npm  okular  papirus-icon-theme
peazip  pipewire  pipewire-alsa  pipewire-jack  pipewire-pulse  plasma-meta
power-profiles-daemon  python-mako  reflector  rocm-smi-lib  scx-scheds  scx-tools
sdl2_ttf  smartmontools  snapper  stow  terminus-font  tldr  trash-cli  tree
tree-sitter-cli  ttf-dejavu  ttf-liberation  ufw  veracrypt  vim  vulkan-headers
vulkan-radeon  wayland-protocols  wgcf  wget  wireplumber  xdg-utils
xf86-video-amdgpu  xf86-video-ati  yad  yazi  zoxide  zsh
steam
```

## 2. chaotic-aur (9)

> Requiere el repo añadido a `/etc/pacman.conf` **antes** de instalar.

```
bibata-cursor-theme  chaotic-keyring  chaotic-mirrorlist  downgrade
limine-mkinitcpio-hook  limine-snapper-sync  wezterm-git  yay  zenergy-dkms-git
```

## 3. AUR / foreign (4)

```
fan2go-git
getnf
sunshine-beta-bin
yay-debug          # ← artefacto de depuración, NO reinstalar
```

## 4. Flatpak (13)

```
app.zen_browser.zen
com.calibre_ebook.calibre
com.discordapp.Discord
com.github.mtkennerly.ludusavi
com.github.tchx84.Flatseal
com.github.wwmm.easyeffects
com.spotify.Client
com.vysp3r.ProtonPlus
community.pathofbuilding.PathOfBuilding
io.github.lawstorant.boxflat
it.mijorus.gearlever
org.localsend.localsend_app
dev.stormix.deadlock-mod-manager   # branch 'master', remote propio (no flathub)
```

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --or-update -y \
  app.zen_browser.zen com.calibre_ebook.calibre com.discordapp.Discord \
  com.github.mtkennerly.ludusavi com.github.tchx84.Flatseal \
  com.github.wwmm.easyeffects com.spotify.Client com.vysp3r.ProtonPlus \
  community.pathofbuilding.PathOfBuilding io.github.lawstorant.boxflat \
  it.mijorus.gearlever org.localsend.localsend_app
```

## 5. AppImage (8)

Ninguna está en pacman/flatpak y **su `.desktop` y sus iconos no están versionados en
dotfiles**: hay que volver a descargarlas y recrear la integración a mano.

### 5.1 En uso, integradas en el menú

| App | Archivo | Tamaño | Integración |
|---|---|---|---|
| Helium (navegador) | `~/AppImages/helium.appimage` | 149 MB | `~/.local/share/applications/helium.desktop` + `~/AppImages/.icons/helium` |
| ACCELA (juego) | `~/AppImages/accela.appimage` | 250 MB | `accela.desktop` + `~/AppImages/.icons/accela` |
| PineconeMC (Minecraft) | `~/AppImages/pineconemc.appimage` | 107 MB | `pineconemc.desktop` + `~/AppImages/.icons/pineconemc` |
| statlocker-companion | `~/Downloads/statlocker-companion_amd64.AppImage` | 304 MB | `statlocker-companion-handler.desktop` (URI handler) |

Plantilla de `.desktop` que usan:

```ini
[Desktop Entry]
Name=Helium
Comment=Access the Internet
Exec=env DESKTOPINTEGRATION=1 /home/azr/AppImages/helium.appimage %U
Icon=/home/azr/AppImages/.icons/helium
Categories=Network;WebBrowser;
Type=Application
Terminal=false
```

```bash
mkdir -p ~/AppImages/.icons
./App/app.appimage --appimage-extract        # extrae a squashfs-root/
cp squashfs-root/*.png ~/AppImages/.icons/<app>
update-desktop-database ~/.local/share/applications
```

### 5.2 Descargadas, sin integración (se lanzan a mano)

```
DesktopEditors-x86_64.AppImage                        626 MB   ONLYOFFICE
OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.4.2.AppImage  138 MB
BambuStudio_ubuntu22.04-v02.08.02.60-*.AppImage       229 MB
opencode-desktop-linux-x86_64.AppImage                274 MB
```

Si se quieren integradas al migrar: usar **GearLever** (`it.mijorus.gearlever`, ya en §4).

### 5.3 Notas

- `statlocker-companion` trae su propio `gpu-screen-recorder` en
  `~/.local/share/statlocker-companion/gsr/` → se autodescarga, **no migrar**.
- `~/AppImages/PineconeMC-Linux-x86_64.AppImage` y `.zs-old` son copias viejas del mismo
  binario que `pineconemc.appimage` (107 MB c/u) → borrables.

## 6. Fuera de pacman/flatpak (3)

| Qué | Dónde | Reinstalar |
|---|---|---|
| `reasonix@1.17.19` | `~/.local/lib/node_modules` | `npm i -g reasonix` |
| `uv` / `uvx` | `~/.local/bin` | instalador oficial de Astral |
| `dotfiles`, `Projects/hid-remapper` | `~` | clones git |

## 7. Servicios a habilitar

```bash
sudo systemctl enable ufw scx_loader lactd fan2go
sudo systemctl enable NetworkManager bluetooth
sudo systemctl enable snapper-cleanup.timer snapper-timeline.timer
```

Habilitados hoy — sistema: `bluetooth`, `fan2go`, `lactd`, `NetworkManager`,
`NetworkManager-dispatcher`, `NetworkManager-wait-online`, `plasmalogin`, `scx_loader`,
`sshd`, `ufw`, `snapper-cleanup.timer`, `snapper-timeline.timer`.
Usuario: `pipewire`, `pipewire-pulse`, `wireplumber`, `xdg-user-dirs`, `p11-kit-server`.

---

## A. Reinstalación paso a paso

```bash
# 1) Base
sudo pacman -S git base-devel reflector

# 2) Chaotic-AUR  (ver scripts/setup_arch.sh líneas 99-106 para el bloque completo)
sudo pacman-key --recv-key 3056513887B8A7AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B8A7AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
# añadir [chaotic-aur] a /etc/pacman.conf

# 3) Mirrors + yay
sudo reflector --latest 20 --fastest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist
git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm

# 4) Paquetes (§1-§3)
yay -S --needed $(cat pkgs-native.txt) $(cat pkgs-foreign.txt)

# 5) Flatpak (§4) y resto (§5-§7)
```

Para re-exportar las listas desde el sistema origen:

```bash
pacman -Qqen > pkgs-native.txt     # repos oficiales + chaotic
pacman -Qqem > pkgs-foreign.txt    # AUR / manuales
flatpak list --app --columns=application,branch,origin
npm ls -g --depth=0
find ~ /opt -maxdepth 5 -iname "*.AppImage" -o -maxdepth 5 -iname "*.appimage" 2>/dev/null
grep -rIl -i appimage ~/.local/share/applications
```

## B. Apéndice — discrepancias con `scripts/setup_arch.sh`

### B.1 En el script pero NO instalados (revisar antes de migrar)

Stack Hyprland completo. El script lo tiene **comentado** (línea 119) y no está instalado
(`Hyprland`, `hyprctl`, `hypridle` no existen en el sistema), aunque `~/dotfiles/hypr` y
`~/dotfiles/noctalia` sí están en el repo:

```
adw-gtk-theme  hyprpolkitagent  hypridle  journalctl-desktop-notification
noctalia-shell  nwg-look  qt6ct-kde  wlsunset
xdg-desktop-portal-gtk  xdg-desktop-portal-hyprland
```

Instalados solo como dependencia (no explícitos): `ddcutil`, `fan2go-git`, `flatpak`,
`fuse3`, `getnf`, `xdg-desktop-portal-gtk`.

El bloque `FLATPAK_PACKAGES` del script nunca se ejecutó: 10 de sus apps se instalan a mano.
Además faltan en el script `com.calibre_ebook.calibre` y `community.pathofbuilding.PathOfBuilding`
(instaladas por Flatpak), y `sunshine-beta-bin` (AUR) pese a existir `~/dotfiles/sunshine`.
Las AppImages no están contempladas en absoluto.

### B.2 Instalados y NO contemplados en el script (59)

```
amd-ucode  base  base-devel  bluez  bluez-utils  boost  btrfs-progs  chaotic-keyring
chaotic-mirrorlist  cmake  compsize  dolphin  efibootmgr  git  gst-plugin-pipewire
gtk-layer-shell  htop  informant  konsole  krfb  libpulse  limine  linux-firmware
magic-wormhole  nano  network-manager-applet  networkmanager  nlohmann-json  nodejs
noto-fonts  noto-fonts-cjk  noto-fonts-emoji  npm  pipewire  pipewire-alsa
pipewire-jack  pipewire-pulse  plasma-meta  reflector  sdl2_ttf  smartmontools
snapper  sudo  sunshine-beta-bin  ttf-dejavu  ttf-liberation  ufw  vim
vulkan-headers  vulkan-radeon  wayland-protocols  wget  wireplumber  wpa_supplicant
xdg-utils  xf86-video-amdgpu  xf86-video-ati  yay  yay-debug
```

Buena parte es **base del sistema / Plasma**, así que el script está desactualizado respecto
al estado real (faltan `plasma-meta`, `limine`, `snapper`, `ufw`, `pipewire*`, `noto-fonts*`,
`nodejs`/`npm`, `xf86-video-*`, `amd-ucode`, `networkmanager`, `btrfs-progs`…).

### B.3 Posibles dependencias de compilación (probablemente no necesarias como explícitas)

```
boost  nlohmann-json  llvm  meson  cmake  sdl2_ttf  vulkan-headers  wayland-protocols
gtk-layer-shell  python-mako  rocm-smi-lib
```

Suelen quedar explícitas por builds de AUR (`wezterm-git`, `zenergy-dkms-git`, `sunshine`,
`scx_*`). Rara vez hace falta reinstalarlas a mano.
