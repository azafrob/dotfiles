#!/bin/bash

set -euo pipefail # Exit on error, undefined vars, and pipe failures

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Error handling
error_exit() {
    log_error "$1"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error_exit "This script should not be run as root!"
    fi
}

# Verify sudo access
check_sudo() {
    if ! sudo -v; then
        error_exit "Sudo access required!"
    fi
}

# Add CachyOS repository
setup_cachyos_repo() {
    log_info "Setting up CachyOS repository..."

    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir" || error_exit "Failed to create temp directory"

    if ! curl -fsSL https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz; then
        error_exit "Failed to download CachyOS repo"
    fi

    tar xf cachyos-repo.tar.xz || error_exit "Failed to extract repo archive"
    cd cachyos-repo || error_exit "Failed to enter repo directory"

    sudo ./cachyos-repo.sh || error_exit "Failed to setup CachyOS repo"

    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"

    log_success "CachyOS repository setup complete"
}

# Update system
update_system() {
    log_info "Updating system packages..."
    sudo pacman -Syu --noconfirm || error_exit "System update failed"
    log_success "System update complete"
}

# Install main packages
install_main_packages() {
    log_info "Installing main packages..."

    local packages=(
        # Kernel and system
        linux-cachyos
        linux-cachyos-headers
        cachyos-settings
        scx-scheds-git
        limine-mkinitcpio-hook
        limine-snapper-sync
        snap-pac
        xdg-desktop-portal-gtk

        # System utilities
        fish
        7zip
        ghostty
        fuse2
        man-db
        tealdeer
        stow
        neovim
        downgrade
        fzf
        zoxide
        eza
        ripgrep
        fd
        fastfetch
        atool
        flatpak
        yazi
        brightnessctl
        amdgpu_top
        libnotify
        playerctl
        btop
        rocm-smi-lib
        git
        lazygit
        unrar
        unzip
        yay
        firefox
        wine
        pavucontrol
        mpv
        luarocks

        # Theming
        kvantum
        nwg-look
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-extra
        ttf-hack-nerd

        # Gaming
        steam
    )

    if ! sudo pacman -S --needed --noconfirm "${packages[@]}"; then
        log_warning "Some main packages failed to install"
    else
        log_success "Main packages installed successfully"
    fi
}

# Install Hyprland packages (commented out in original)
install_hyprland_packages() {
    log_info "Installing Hyprland packages..."

    local hyprland_packages=(
        xdg-desktop-portal-hyprland
        waybar
        hyprpaper
        dunst
        wofi
        hyprlock
        hypridle
        grim
        slurp
        wl-clipboard
    )

    if ! sudo pacman -S --needed --noconfirm "${hyprland_packages[@]}"; then
        log_warning "Some Hyprland packa/ges failed to install"
    else
        log_success "Hyprland packages installed successfully"
    fi
}

# Install AUR packages
install_aur_packages() {
    log_info "Installing AUR packages..."

    local aur_packages=(
        gamescope-git
        fan2go-git
        lact-git
        papirus-icon-theme-git
        bibata-cursor-theme
        catppuccin-gtk-theme-mocha
        zenergy-dkms-git
        gamemode-git
        mangohud-git
        qt6ct-kde
        journalctl-desktop-notification
        arkenfox-user.js
    )

    if ! yay -S --needed --noconfirm "${aur_packages[@]}"; then
        log_warning "Some AUR packages failed to install"
    else
        log_success "AUR packages installed successfully"
    fi
}

# Setup Flatpak
setup_flatpak() {
    log_info "Setting up Flatpak..."

    local flatpak_packages=(
        org.qbittorrent.qBittorrent
        org.jdownloader.JDownloader
        com.github.Matoking.protontricks
        com.vysp3r.ProtonPlus
        dev.vencord.Vesktop
        com.github.tchx84.Flatseal
        it.mijorus.gearlever
    )

    if flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
        log_success "Flathub repository added"
    else
        log_warning "Failed to add Flathub repository"
    fi

    if ! flatpak install -y --noninteractive flathub "${flatpak_packages[@]}"; then
        log_warning "Some flatpak packages failed to install"
    else
        log_success "Flatpak packages installed successfully"
    fi
}

# Setup Sunshine streaming
setup_sunshine() {
    log_info "Setting up Sunshine streaming server..."

    if ! grep -qE 'lizardbyte(-beta)?' /etc/pacman.conf; then
        # Add Sunshine repositories
        {
            echo ""
            echo "[lizardbyte-beta]"
            echo "SigLevel = Optional"
            echo "Server = https://github.com/LizardByte/pacman-repo/releases/download/beta"
            echo ""
            echo "[lizardbyte]"
            echo "SigLevel = Optional"
            echo "Server = https://github.com/LizardByte/pacman-repo/releases/latest/download"
        } | sudo tee -a /etc/pacman.conf > /dev/null
    else
        log_warning "Sunshine repo already in pacman.conf"
    fi

    # Update package database
    sudo pacman -Sy || log_warning "Failed to update package database"

    # Install Sunshine
    if sudo pacman -S --noconfirm lizardbyte-beta/sunshine-git; then
        log_success "Sunshine installed successfully"
    else
        log_warning "Failed to install Sunshine"
    fi

    # Enable Sunshine daemon
    log_info "Enabling Sunshine daemon..."
    systemctl --user enable --now sunshine.service || log_warning "Failed to enable Sunshine daemon"
}

# Configure system settings
configure_system() {
    log_info "Configuring system settings..."

    cd ~/dotfiles

    # Motherboard fan controller module
    log_info "Adding motherboard fan controller module..."
    if [ ! -e /etc/modules-load.d/custom_modules.conf ]; then
        echo "nct6775" | sudo tee "/etc/modules-load.d/custom_modules.conf" > /dev/null
    else
        log_warning "Module already exists"
    fi

    # Enable limine-snapper-sync
    log_info "Enabling limine-snapper-sync"
    sudo systemctl enable --now limine-snapper-sync.service || log_warning "Failed to enable limine-snapper-sync daemon"

    # Enable journalctl-desktop-notification
    log_info "Enabling journalctl-desktop-notification"
    systemctl enable --now journalctl-desktop-notification.service || log_warning "Failed to enable journalctl-desktop-notification daemon"

    # SCX scheduler configuration
    log_info "Configuring SCX scheduler..."
    if [ ! -e /etc/scx_loader.toml ]; then
        sudo stow -t / scx_loader || log_warning "Failed to stow scx_loader config"
    else
        log_warning "Scx_loader config already exists"
    fi
    sudo systemctl disable --now scx.service 2>/dev/null || true
    sudo systemctl enable --now scx_loader.service || log_warning "Failed to enable scx_loader daemon"

    # Change shell to fish
    log_info "Changing shell to fish..."
    chsh -s /usr/bin/fish

    # Disable ananicy-cpp in favor of scx
    log_info "Disabling ananicy-cpp..."
    sudo systemctl disable --now ananicy-cpp 2>/dev/null || true

    # Enable LACT daemon
    log_info "Enabling LACT daemon..."
    sudo systemctl enable --now lactd || log_warning "Failed to enable LACT daemon"

    # Enable Wake-on-LAN
    log_info "Enabling Wake-on-LAN..."
    if nmcli c modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic; then
        log_success "Wake-on-LAN enabled"
    else
        log_warning "Failed to enable Wake-on-LAN (connection name might differ)"
    fi

    # Enable fan2go
    log_info "Enabling fan2go..."
    if [ ! -e /etc/fan2go/fan2go.yaml ]; then
        sudo stow -t / fan2go || log_warning "Failed to stow fan2go config"
    else
        log_warning "Fan2go config already exists"
    fi
    sudo systemctl enable --now fan2go.service || log_warning "Failed to enable fan2go daemon"

    # Setup EDID virtual display
    log_info "Enabling virtual display..."
    sudo mkdir -p /usr/lib/firmware/edid || log_warning "Failed to create edid directory"
    sudo cp ~/dotfiles/modified-edid /usr/lib/firmware/edid/ || log_warning "Failed to copy EDID"
    if [ ! -e /etc/mkinitcpio.conf.d/edid.conf ]; then
        sudo touch /etc/mkinitcpio.conf.d/edid.conf || log_warning "Failed to create edid.conf"
        echo "FILES=(/usr/lib/firmware/edid/modified-edid)" | sudo tee -a /etc/mkinitcpio.conf.d/edid.conf > /dev/null
    else
        log_warning "Edid mkinitcpio override already exists"
    fi
    if [ ! -e /etc/default/limine ]; then
        sudo cp /etc/limine-entry-tool.conf /etc/default/limine || log_warning "Failed to copy limine-entry-tool config"
        cmdline=$(cat /proc/cmdline)
        extra_params=" drm.edid_firmware=HDMI-A-1:edid/modified-edid video=HDMI-A-1:e"
        echo "KERNEL_CMDLINE[\"linux-cachyos\"]=\"${cmdline}${extra_params}\"" | sudo tee -a /etc/default/limine > /dev/null
    else
        log_warning "Limine-entry-tool config already exists"
    fi
    sudo limine-mkinitcpio

    # Setup ly config
    log_info "Setup ly config"
    if [ ! -e /etc/ly/config.ini ]; then
        sudo stow -t / ly || log_warning "Failed to stow ly"
    else
        sudo rm /etc/ly/config.ini || log_warning "Failed to remove existent ly config"
        sudo stow -t / ly || log_warning "Failed to stow ly"
    fi

    # Update tldr pages
    log_info "Updating tldr pages..."
    tldr --update || log_warning "Failed to update tldr pages"

    # TODO Theme kvantum, nwg-look and qt6ct

    # TODO Setup Firefox with Arkenfox

    # Setup git
    log_info "Setup git"
    git config --global user.name "Adrian"
    git config --global user.email "noreply@adrian.com"
    if [ ! -e ~/.ssh/id_ed25519 ]; then
        ssh-keygen -t ed25519 -C "noreply@adrian.com"
    else
        log_warning "Ssh already exists"
    fi
    log_info "Add this key to github"
    echo "-----BEGIN PUBLIC KEY-----"
    cat ~/.ssh/id_ed25519.pub
    echo "-----END PUBLIC KEY-----"

    # Setup Chaotic AUR repo
    log_info "Setup Chaotic AUR repo"
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    if ! grep -qE 'chaotic-aur' /etc/pacman.conf; then
        # Add Chaotic AUR repo
        {
            echo ""
            echo "[chaotic-aur]"
            echo "Include = /etc/pacman.d/chaotic-mirrorlist"
        } | sudo tee -a /etc/pacman.conf > /dev/null
    else
        log_warning "Chaotic AUR repo already in pacman.conf"
    fi

    log_success "System configuration complete"
}

stow_config() {
    log_info "Stowing config..."
    stow_packages=(
        fish
        ghostty
        fontconfig
        hypr
        btop
        dunst
        mangohud
        nvim
        SLSsteam
        waybar
        yazi
        wofi
        sunshine
    )

    cd ~/dotfiles

    # Stow packages, removing existing config directories in ~/.config first
    for package in "${stow_packages[@]}"; do
        target_dir="$HOME/.config/$package"

        # Check if the target directory exists in ~/.config
        if [ -e "$target_dir" ]; then
            log_info "Found existing config for $package, removing $target_dir"
            # If it exists, remove it
            rm -rf "$target_dir"
        fi

        stow "$package" || log_warning "Failed to stow $package"
    done

    stow wallpapers || log_warning "Failed to stow wallpapers"

    log_success "Stowing complete"
}

# Main execution flow
main() {
    log_info "Starting system setup..."

    check_root
    check_sudo

    # Keep sudo alive
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    setup_cachyos_repo
    update_system
    install_main_packages
    install_hyprland_packages # Comment if you don't want to install Hyprland packages
    install_aur_packages
    setup_flatpak
    setup_sunshine
    configure_system
    stow_config

    log_success "System setup completed successfully!"
    log_info "Please reboot your system to ensure all changes take effect."
}

# Run main function only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
