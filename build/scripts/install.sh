#!/bin/bash
# Zephyrus Crimson OS - Installation Script
# Installs Zephyrus Crimson OS on a Bazzite system

set -e

# Configuration
ZEPHYRUS_VERSION="1.0.0"
IMAGE_REPO="ghcr.io/solarious"
IMAGE_NAME="zephyrus-crimson"
IMAGE_TAG="${ZEPHYRUS_VERSION}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[ZEPHYRUS INSTALL]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running on Bazzite/OSTree system
check_system() {
    log "Checking system compatibility..."
    
    if ! command -v rpm-ostree &> /dev/null; then
        error "This installer requires an rpm-ostree based system (Bazzite, Fedora Silverblue, etc.)"
        exit 1
    fi
    
    if ! command -v bootc &> /dev/null; then
        error "bootc not found. This is required for system installation."
        exit 1
    fi
    
    log "System check passed"
}

# Check for container engine
check_container_engine() {
    if command -v podman &> /dev/null; then
        CONTAINER_ENGINE="podman"
    elif command -v docker &> /dev/null; then
        CONTAINER_ENGINE="docker"
    else
        error "No container engine found (podman or docker required)"
        exit 1
    fi
    
    log "Using container engine: ${CONTAINER_ENGINE}"
}

# Display welcome screen
welcome() {
    clear
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║           ZEPHYRUS CRIMSON OS - INSTALLER                      ║
║                                                                ║
║              ASUS ROG Edition Linux Distribution               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

This will install Zephyrus Crimson OS on your system.

Features:
  • macOS-style global menu bar
  • ROG branded system theme
  • Hardware-optimized for Zephyrus G16
  • Custom boot animation
  • ROG system menu

WARNING: This will modify your system.
Please ensure you have backups of important data.

EOF
    
    read -p "Continue with installation? (yes/no): " confirm
    if [[ ! "$confirm" =~ ^[Yy][Ee][Ss]$ ]]; then
        log "Installation cancelled"
        exit 0
    fi
}

# Check available disk space
check_disk_space() {
    log "Checking disk space..."
    
    available=$(df / | tail -1 | awk '{print $4}')
    # Convert to GB (roughly)
    available_gb=$((available / 1024 / 1024))
    
    if [ "$available_gb" -lt 20 ]; then
        error "Insufficient disk space. At least 20GB required."
        exit 1
    fi
    
    log "Disk space check passed (${available_gb}GB available)"
}

# Pull image
pull_image() {
    log "Pulling Zephyrus Crimson OS image..."
    
    FULL_IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
    
    info "Image: ${FULL_IMAGE}"
    
    ${CONTAINER_ENGINE} pull "${FULL_IMAGE}"
    
    log "Image pulled successfully"
}

# Install system
install_system() {
    log "Installing Zephyrus Crimson OS..."
    
    FULL_IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
    
    # Use bootc to switch to the new image
    info "Switching system to Zephyrus Crimson OS..."
    sudo bootc switch --transport containers-storage "${FULL_IMAGE}"
    
    log "System installation complete!"
}

# Post-install configuration
post_install() {
    log "Configuring system..."
    
    # Mark as Zephyrus system
    echo "Zephyrus Crimson OS ${ZEPHYRUS_VERSION}" | sudo tee /etc/zephyrus-release > /dev/null
    
    # Set hostname if desired
    read -p "Set hostname to 'zephyrus-crimson'? (y/n): " set_hostname
    if [[ "$set_hostname" =~ ^[Yy]$ ]]; then
        sudo hostnamectl set-hostname zephyrus-crimson
        log "Hostname set to 'zephyrus-crimson'"
    fi
    
    log "Configuration complete"
}

# Reboot prompt
prompt_reboot() {
    echo ""
    log "╔════════════════════════════════════════════════════════════╗"
    log "║  Installation Complete!                                    ║"
    log "║                                                            ║"
    log "║  Please reboot your system to start using                  ║"
    log "║  Zephyrus Crimson OS.                                      ║"
    log "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    read -p "Reboot now? (y/n): " reboot_now
    if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
        log "Rebooting..."
        sudo systemctl reboot
    else
        log "Please reboot manually when ready"
        log "Command: sudo systemctl reboot"
    fi
}

# Main installation flow
main() {
    welcome
    check_system
    check_container_engine
    check_disk_space
    pull_image
    install_system
    post_install
    prompt_reboot
}

# Handle command line arguments
case "${1:-}" in
    --version|-v)
        echo "Zephyrus Crimson OS Installer v${ZEPHYRUS_VERSION}"
        exit 0
        ;;
    --help|-h)
        cat << EOF
Zephyrus Crimson OS Installer

Usage: $0 [OPTIONS]

Options:
  --version, -v    Show version
  --help, -h       Show this help
  --local          Use local image (for development)

Environment Variables:
  IMAGE_REPO       Container registry (default: ghcr.io/solarious)
  IMAGE_NAME       Image name (default: zephyrus-crimson)
  IMAGE_TAG        Image tag (default: 1.0.0)

EOF
        exit 0
        ;;
    --local)
        # Use local image for development
        IMAGE_REPO="localhost"
        main
        ;;
    *)
        main
        ;;
esac
