#!/bin/bash
# Zephyrus Crimson OS - ISO Builder
# Creates bootable installation media

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/output"
CACHE_DIR="${SCRIPT_DIR}/cache"

# Configuration
IMAGE_NAME="zephyrus-crimson"
VERSION="1.0.0"
ISO_NAME="zephyrus-crimson-${VERSION}.iso"

log() {
    echo -e "\033[1;32m[ISO BUILD]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
    exit 1
}

# Check for required tools
check_tools() {
    log "Checking required tools..."
    
    if ! command -v bootc-image-builder &> /dev/null; then
        error "bootc-image-builder not found"
        log "Install with: sudo rpm-ostree install bootc-image-builder"
        exit 1
    fi
    
    if ! command -v podman &> /dev/null && ! command -v docker &> /dev/null; then
        error "Container engine not found (podman or docker required)"
        exit 1
    fi
    
    log "All tools available"
}

# Build ISO
build_iso() {
    log "Building installation ISO..."
    log "Output: ${OUTPUT_DIR}/${ISO_NAME}"
    
    mkdir -p "${OUTPUT_DIR}"
    
    # Check if we have a built image
    if ! ${CONTAINER_ENGINE:-podman} image exists "${IMAGE_NAME}:${VERSION}" 2>/dev/null; then
        log "Building container image first..."
        "${SCRIPT_DIR}/build.sh" --no-push
    fi
    
    # Build ISO using bootc-image-builder
    bootc-image-builder build \
        --type iso \
        --output "${OUTPUT_DIR}" \
        "${IMAGE_NAME}:${VERSION}"
    
    log "ISO built successfully!"
    log "Location: ${OUTPUT_DIR}/${ISO_NAME}"
}

# Main
main() {
    log "Zephyrus Crimson OS - ISO Builder"
    log "================================="
    
    check_tools
    build_iso
    
    log ""
    log "================================="
    log "Build complete!"
    log "================================="
    log ""
    log "To test the ISO:"
    log "  - Flash to USB: sudo dd if=${OUTPUT_DIR}/${ISO_NAME} of=/dev/sdX bs=4M status=progress"
    log "  - Or use: ventoy, balenaEtcher, etc."
    log ""
}

main "$@"
