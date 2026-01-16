#!/usr/bin/env bash

# Exit on error, unset variable, pipe failure
set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install yay if not present
install_yay() {
    if ! command_exists yay; then
        log_info "yay not found. Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        cd - > /dev/null
        rm -rf /tmp/yay
        log_success "yay installed successfully"
    fi
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Function to prompt user for confirmation
confirm_action() {
    read -rp "$1 (y/N): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Array of packages (better than string for expansion)
packages=(
    # Core desktop components
    python-setuptools polybar rofi alacritty picom-ftlabs-git dunst
    # GUI toolkits
    gtk3 gtk4 qt6-svg qt6-declarative qt5-quickcontrols2
    # Audio
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber alsa-utils pamixer
    # Utilities
    feh brightnessctl bluez-utils i3lock-color
    # Desktop tools
    yad xclip stalonetray maim gpick imagemagick ffmpeg
    # Fonts
    ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-sarasa-gothic ttf-roboto
    # Music
    mpd mpdris2 ncmpcpp playerctl
    # Power management
    xfce4-power-manager
    # Notifications
    libnotify notify-send-py
    # X11 utilities
    xdo xsettingsd
    # Theming
    lxappearance catppuccin-cursors-mocha catppuccin-gtk-theme-mocha
    # Archives
    unzip
    # Python
    python3 python-gobject
)

# SDDM theme configuration
SDDM_THEME_URL="https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-mocha-mauve-sddm.zip"
SDDM_THEME_NAME="catppuccin-mocha-mauve"
SDDM_THEME_DIR="/usr/share/sddm/themes"

# Main installation function
install_packages() {
    log_info "Installing base-devel..."
    yay -S --needed --noconfirm base-devel
    
    log_info "Installing packages..."
    yay -S --needed --noconfirm "${packages[@]}"
    
    log_success "Packages installed successfully"
}

# Install SDDM theme
install_sddm_theme() {
    if ! confirm_action "Install Catppuccin SDDM theme?"; then
        return
    fi
    
    log_info "Installing SDDM theme..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    
    # Check if theme already exists
    if [[ -d "${SDDM_THEME_DIR}/${SDDM_THEME_NAME}" ]]; then
        log_warning "SDDM theme already exists. Do you want to update it?"
        if confirm_action "Update existing theme?"; then
            sudo rm -rf "${SDDM_THEME_DIR}/${SDDM_THEME_NAME}"
        else
            log_info "Skipping SDDM theme installation"
            rm -rf "$TEMP_DIR"
            return
        fi
    fi
    
    # Download and extract theme
    log_info "Downloading SDDM theme..."
    if command_exists wget; then
        wget -q "$SDDM_THEME_URL" -O "$TEMP_DIR/sddm-theme.zip"
    elif command_exists curl; then
        curl -sL "$SDDM_THEME_URL" -o "$TEMP_DIR/sddm-theme.zip"
    else
        log_error "Neither wget nor curl found. Installing wget..."
        yay -S --noconfirm wget
        wget -q "$SDDM_THEME_URL" -O "$TEMP_DIR/sddm-theme.zip"
    fi
    
    # Extract theme
    log_info "Extracting theme..."
    unzip -q "$TEMP_DIR/sddm-theme.zip" -d "$TEMP_DIR"
    
    # Create theme directory if it doesn't exist
    sudo mkdir -p "$SDDM_THEME_DIR"
    
    # Install theme
    log_info "Moving theme to system directory..."
    sudo mv -v "$TEMP_DIR/$SDDM_THEME_NAME" "$SDDM_THEME_DIR/"
    
    # Copy SDDM config if it exists locally
    if [[ -f "sddm/sddm.conf" ]]; then
        log_info "Copying SDDM configuration..."
        sudo cp -v "sddm/sddm.conf" "/etc/sddm.conf"
    else
        log_warning "Local sddm.conf not found in sddm/ directory"
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    log_success "SDDM theme installed successfully"
}

# Backup existing configs
backup_configs() {
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
    
    if confirm_action "Backup existing configs to $backup_dir?"; then
        mkdir -p "$backup_dir"
        
        # Backup common config directories
        for dir in i3 polybar alacritty rofi picom dunst; do
            if [[ -d "$HOME/.config/$dir" ]]; then
                cp -r "$HOME/.config/$dir" "$backup_dir/$dir"
                log_info "Backed up $dir config"
            fi
        done
        
        log_success "Configs backed up to $backup_dir"
    fi
}

# Copy configs from repository
copy_configs() {
    if confirm_action "Copy configuration files from repository?"; then
        # Check if .config directory exists in repo
        if [[ -d "./.config" ]]; then
            cp -r ./.config/* "$HOME/.config/"
            log_info "Copied .config files"
        fi
        
        # Copy wallpaper if exists
        if [[ -f "./.config/wallpapers/mocha.png" ]]; then
            cp "./.config/wallpapers/mocha.png" "$HOME/.wall"
            log_info "Copied wallpaper"
        fi
        
        # Copy lockscreen if exists
        if [[ -f "./.config/wallpapers/lockscreen.png" ]]; then
            cp "./.config/wallpapers/lockscreen.png" "$HOME/.lock"
            log_info "Copied lockscreen"
        fi

        # Make scripts executable
        if [[ -d "$HOME/.config/scripts" ]]; then
            find "$HOME/.config/scripts" -type f -name "*.sh" -exec chmod +x {} \;
            find "$HOME/.config/scripts" -type f -name "*.py" -exec chmod +x {} \;
            log_info "Made scripts executable"
        fi
        
        log_success "Configuration files copied"
    fi
}

# Main execution
main() {
    log_info "Starting system setup..."
    check_root
    install_yay
    install_packages
    install_sddm_theme
    backup_configs
    copy_configs
    
    log_success "Setup completed!"
    log_info "You may need to:"
    echo "  1. Enable SDDM: sudo systemctl enable sddm"
    echo "  2. Reboot or restart display manager"
    echo "  3. Configure remaining settings manually"
}

# Parse command line arguments
if [[ $# -gt 0 ]]; then
    case $1 in
        --help|-h)
            echo "Usage: $0 [OPTION]"
            echo "Install and configure system packages and themes"
            echo ""
            echo "Options:"
            echo "  -h, --help     Show this help message"
            echo "  --packages     Install packages only"
            echo "  --sddm         Install SDDM theme only"
            echo "  --configs      Copy configs only"
            echo "  --backup       Backup existing configs only"
            ;;
        --packages)
            check_root
            install_yay
            install_packages
            ;;
        --sddm)
            check_root
            install_sddm_theme
            ;;
        --configs)
            copy_configs
            ;;
        --backup)
            backup_configs
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
else
    main
fi