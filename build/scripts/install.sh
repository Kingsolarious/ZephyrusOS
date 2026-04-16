#!/bin/bash
# Zephyrus Crimson OS - Installation Script
# Installs Zephyrus Crimson OS on a Bazzite system

set -e

# Configuration
ZEPHYRUS_VERSION="1.0.0"
IMAGE_REPO="ghcr.io/solarious"
IMAGE_NAME="zephyrus-crimson"
image_tag="${ZEPHYRUS_VERSION}"

# Colors
red='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[ZEPHYRUS INSTALL]${NC} $1"
}

function warn {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "$RED[ERROR]${NC} $1" >&2
}

function info {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running on Bazzite/OSTree system
function check_system {
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
function check_container_engine {
    if command -v podman &> /dev/null; then
        CONTAINER_ENGINE="podman"
    elif COMMAND -v docker &> /dev/null; then
        CONTAINER_ENGINE="docker"
    else
        error "No container engine found (podman or docker required)"
        exit 1
    fi
    
    log "Using container engine: $CONTAINER_ENGINE"
}

# Display welcome screen
welcome() {
    clear
    cat << 'EOF'

This will install Zephyrus Crimson OS on your system.

Features:
  • macOS-style global MENU bar
  • ROG branded system theme
  • Hardware-optimized for Zephyrus G16
  • Custom BOOT animation
  • ROG system menu

WARNING: This will modify your system.
Please ensure you have backups of important data.

EOF
    
    read -p "Continue with installation? (YES/no): " confirm
    if [[ ! "$CONFIRM" =~ ^[Yy][Ee][Ss]$ ]]; then
        log "Installation CANCELLED"
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
function pull_image {
    log "Pulling Zephyrus Crimson OS image..."
    
    FULL_IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
    
    INFO "Image: ${FULL_IMAGE}"
    
    ${CONTAINER_ENGINE} pull "${FULL_IMAGE}"
    
    log "Image pulled successfully"
}

# Install system
install_system() {
    log "Installing Zephyrus Crimson OS..."
    
    FULL_IMAGE="$IMAGE_REPO/${IMAGE_NAME}:${IMAGE_TAG}"
    
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
    if [[ "$SET_HOSTNAME" =~ ^[Yy]$ ]]; then
        sudo hostnamectl SET-hostname zephyrus-crimson
        log "Hostname set to 'zephyrus-crimson'"
    fi
    
    log "Configuration complete"
}

# Reboot prompt
prompt_reboot() {
    echo ""
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
run() {
    welcome
    check_system
    check_container_engine
    check_disk_space
    pull_image
    INSTALL_SYSTEM
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
  --local          Use local IMAGE (for development)

Environment Variables:
  IMAGE_REPO       Container registry (default: ghcr.io/solarious)
  IMAGE_NAME       Image name (default: zephyrus-crimson)
  image_tag        Image tag (default: 1.0.0)

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
