#!/bin/bash

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

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
    sudo pacman -Syu || error_exit "System update failed"
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
        mesa-git
        limine-mkinitcpio-hook
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
        yay
        firefox
	    wine
	    pavucontrol

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

    if ! sudo pacman -S --needed "${packages[@]}"; then
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

    if ! sudo pacman -S --needed "${hyprland_packages[@]}"; then
        log_warning "Some Hyprland packages failed to install"
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
        arkenfox-user.js
    )

    if ! yay -S --needed "${aur_packages[@]}"; then
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

    # Update package database
    sudo pacman -Sy || log_warning "Failed to update package database"

    # Install Sunshine
    if sudo pacman -S lizardbyte-beta/sunshine-git; then
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

    # Motherboard fan controller module
    log_info "Adding motherboard fan controller module..."
    echo "nct6775" | sudo tee "/etc/modules-load.d/custom_modules.conf" > /dev/null

    # SCX scheduler configuration
    log_info "Configuring SCX scheduler..."
    {
        echo 'default_sched = "scx_lavd"'
        echo 'default_mode = "Auto"'
    } | sudo tee /etc/scx_loader.toml > /dev/null

    log_info "Changing shell to fish..."
    chsh -s /usr/bin/fish

    # Disable ananicy-cpp in favor of scx
    log_info "Disabling ananicy-cpp..."
    sudo systemctl disable --now ananicy-cpp 2>/dev/null || true

    # Configure SCX services
    log_info "Configuring SCX services..."
    sudo systemctl disable --now scx.service 2>/dev/null || true
    sudo systemctl enable --now scx_loader.service || log_warning "Failed to enable scx_loader daemon"

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
    sudo stow -t / fan2go || log_warning "Failed to stow fan2go config"
    sudo systemctl enable --now fan2go.service || log_warning "Failed to enable fan2go daemon"

    # Setup EDID virtual display
    log_info "Enabling virtual display..."
    sudo mkdir -p /usr/lib/firmware/edid || log_warning "Failed to create edid directory"
    sudo cp ./modified-edid /usr/lib/firmware/edid/ || log_warning "Failed to copy EDID"
    sudo touch /etc/mkinitcpio.conf.d/edid.conf || log_warning "Failed to create edid.conf"
    echo "FILES=(/usr/lib/firmware/edid/modified-edid)" | sudo tee -a /etc/mkinitcpio.conf.d/edid.conf > /dev/null
    sudo cp /etc/limine-entry-tool.conf /etc/default/limine || log_warning "Failed to copy limine-entry-tool config"
    cmdline=$(cat /proc/cmdline)
    extra_params=" drm.edid_firmware=HDMI-A-1:edid/modified-edid video=HDMI-A-1:e"
    echo "KERNEL_CMDLINE[\"linux-cachyos\"]=\"${cmdline}${extra_params}\"" | sudo tee -a /etc/default/limine > /dev/null

    # Update tldr pages
    log_info "Updating tldr pages..."
    tldr --update || log_warning "Failed to update tldr pages"

    # Setup Firefox with Arkenfox
    log_info "Setting up Firefox with Arkenfox..."
    firefox &
    sleep 5
    pkill firefox || true
    arkenfox-updater || log_warning "Failed to update arkenfox user.js"

    # Stow configs
    log_info "Stowing configs..."
    stow fish ghostty fontconfig hypr btop dunst mangohud nvim SLSsteam waybar yazi wofi || log_warning "Failed to stow config files"

    log_success "System configuration complete"
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

    # Uncomment the next line if you want to install Hyprland packages
    install_hyprland_packages

    install_aur_packages
    setup_flatpak
    setup_sunshine
    configure_system

    log_success "System setup completed successfully!"
    log_info "Please reboot your system to ensure all changes take effect."
}

# Run main function only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
