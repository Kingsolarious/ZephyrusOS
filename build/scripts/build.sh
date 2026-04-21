#!/bin/bash
# Zephyrus Crimson OS - Build Script
# Builds a custom Bazzite-based OS image with full ROG branding

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${SCRIPT_DIR}/build"
CACHE_DIR="${SCRIPT_DIR}/cache"
OUTPUT_DIR="${SCRIPT_DIR}/output"

# Build configuration
ZEPHYRUS_VERSION="1.0.0"
ZEPHYRUS_BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BASE_IMAGE="ghcr.io/ublue-os/bazzite-gnome"
BASE_TAG="stable"
IMAGE_NAME="zephyrus-crimson"
IMAGE_TAG="${ZEPHYRUS_VERSION}"
REGISTRY="ghcr.io/solarious"

# =============================================================================
# FUNCTIONS
# =============================================================================

log() {
    echo -e "\033[1;32m[ZEPHYRUS BUILD]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
    exit 1
}

warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

# =============================================================================
# PREREQUISITES CHECK
# =============================================================================

check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check for podman or docker
    if command -v podman &> /dev/null; then
        CONTAINER_ENGINE="podman"
    elif command -v docker &> /dev/null; then
        CONTAINER_ENGINE="docker"
    else
        error "Neither podman nor docker found. Please install one of them."
    fi
    
    log "Using container engine: ${CONTAINER_ENGINE}"
    
    # Check for buildah (optional but recommended)
    if command -v buildah &> /dev/null; then
        log "Buildah found (for advanced builds)"
        HAS_BUILDAH=1
    else
        warn "Buildah not found (optional)"
        HAS_BUILDAH=0
    fi
    
    # Check for skopeo
    if ! command -v skopeo &> /dev/null; then
        warn "Skopeo not found (optional, for image copying)"
    fi
}

# =============================================================================
# PREPARE BUILD
# =============================================================================

prepare_build() {
    log "Preparing build environment..."
    
    # Create directories
    mkdir -p "${BUILD_DIR}" "${CACHE_DIR}" "${OUTPUT_DIR}"
    
    # Copy extension to build context
    log "Copying extension..."
    cp -r "${PROJECT_ROOT}/extension" "${BUILD_DIR}/"
    
    # Copy about app
    log "Copying About app..."
    cp -r "${PROJECT_ROOT}/zephyrus-about" "${BUILD_DIR}/"
    
    # Copy theme files (if they exist)
    if [ -d "${PROJECT_ROOT}/theme" ]; then
        log "Copying themes..."
        cp -r "${PROJECT_ROOT}/theme" "${BUILD_DIR}/"
    else
        warn "Theme directory not found, creating minimal theme..."
        mkdir -p "${BUILD_DIR}/theme"
    fi
    
    # Copy icons (if they exist)
    if [ -d "${PROJECT_ROOT}/icons" ]; then
        log "Copying icons..."
        cp -r "${PROJECT_ROOT}/icons" "${BUILD_DIR}/"
    else
        mkdir -p "${BUILD_DIR}/icons"
    fi
    
    # Copy GDM assets
    log "Copying GDM assets..."
    cp -r "${PROJECT_ROOT}/gdm" "${BUILD_DIR}/"
    
    # Copy Plymouth theme
    log "Copying Plymouth theme..."
    cp -r "${PROJECT_ROOT}/plymouth" "${BUILD_DIR}/"
    
    # Copy overlay files
    log "Copying system overlays..."
    cp -r "${SCRIPT_DIR}/overlays" "${BUILD_DIR}/"
    
    # Copy custom asusctl source if available (exclude .git)
    if [ -d "/home/solarious/asusctl" ]; then
        log "Copying custom asusctl source..."
        mkdir -p "${BUILD_DIR}/custom-asusctl"
        rsync -a --exclude='.git' "/home/solarious/asusctl/" "${BUILD_DIR}/custom-asusctl/"
    fi
    
    # Copy Containerfile
    cp "${SCRIPT_DIR}/Containerfile" "${BUILD_DIR}/"
    
    log "Build environment ready at: ${BUILD_DIR}"
}

# =============================================================================
# BUILD IMAGE
# =============================================================================

build_image() {
    log "Building Zephyrus Crimson OS image..."
    log "Version: ${ZEPHYRUS_VERSION}"
    log "Build Date: ${ZEPHYRUS_BUILD_DATE}"
    log "Base Image: ${BASE_IMAGE}:${BASE_TAG}"
    
    cd "${BUILD_DIR}"
    
    # Build the container image
    ${CONTAINER_ENGINE} build \
        --file Containerfile \
        --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
        --tag "${IMAGE_NAME}:latest" \
        --build-arg ZEPHYRUS_VERSION="${ZEPHYRUS_VERSION}" \
        --build-arg ZEPHYRUS_BUILD_DATE="${ZEPHYRUS_BUILD_DATE}" \
        --build-arg BASE_IMAGE="${BASE_IMAGE}" \
        --build-arg BASE_TAG="${BASE_TAG}" \
        --cache-from "${CACHE_DIR}" \
        --progress=plain \
        .
    
    log "Container image built successfully!"
}

# =============================================================================
# EXPORT IMAGE
# =============================================================================

export_image() {
    log "Exporting image..."
    
    # Export as OCI archive
    ${CONTAINER_ENGINE} save \
        --output "${OUTPUT_DIR}/${IMAGE_NAME}-${ZEPHYRUS_VERSION}.tar" \
        "${IMAGE_NAME}:${IMAGE_TAG}"
    
    # Compress
    log "Compressing image..."
    gzip -f "${OUTPUT_DIR}/${IMAGE_NAME}-${ZEPHYRUS_VERSION}.tar"
    
    log "Image exported to: ${OUTPUT_DIR}/${IMAGE_NAME}-${ZEPHYRUS_VERSION}.tar.gz"
}

# =============================================================================
# PUSH TO REGISTRY
# =============================================================================

push_image() {
    if [ -z "${SKIP_PUSH}" ]; then
        log "Pushing to registry..."
        
        # Tag with registry
        ${CONTAINER_ENGINE} tag "${IMAGE_NAME}:${IMAGE_TAG}" \
            "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        ${CONTAINER_ENGINE} tag "${IMAGE_NAME}:latest" \
            "${REGISTRY}/${IMAGE_NAME}:latest"
        
        # Push
        ${CONTAINER_ENGINE} push "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        ${CONTAINER_ENGINE} push "${REGISTRY}/${IMAGE_NAME}:latest"
        
        log "Image pushed to: ${REGISTRY}/${IMAGE_NAME}"
    fi
}

# =============================================================================
# BUILD ISO
# =============================================================================

build_iso() {
    if [ -n "${BUILD_ISO}" ]; then
        log "Building installation ISO..."
        
        # This requires additional tools like lorax or bootc-image-builder
        if command -v bootc-image-builder &> /dev/null; then
            log "Using bootc-image-builder..."
            
            bootc-image-builder build \
                --type iso \
                --output "${OUTPUT_DIR}" \
                "${IMAGE_NAME}:${IMAGE_TAG}"
            
            log "ISO built: ${OUTPUT_DIR}/*.iso"
        else
            warn "bootc-image-builder not found, skipping ISO build"
            warn "Install with: sudo rpm-ostree install bootc-image-builder"
        fi
    fi
}

# =============================================================================
# CLEANUP
# =============================================================================

cleanup() {
    if [ -n "${CLEAN_BUILD}" ]; then
        log "Cleaning up build directory..."
        rm -rf "${BUILD_DIR}"
    fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    log "Zephyrus Crimson OS Build System"
    log "================================"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                CLEAN_BUILD=1
                shift
                ;;
            --iso)
                BUILD_ISO=1
                shift
                ;;
            --push)
                SKIP_PUSH=""
                shift
                ;;
            --no-push)
                SKIP_PUSH=1
                shift
                ;;
            --version)
                ZEPHYRUS_VERSION="$2"
                shift 2
                ;;
            --base)
                BASE_IMAGE="$2"
                shift 2
                ;;
            --tag)
                BASE_TAG="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --clean        Clean build directory first"
                echo "  --iso          Build installation ISO"
                echo "  --push         Push to registry (default)"
                echo "  --no-push      Skip pushing to registry"
                echo "  --version      Set version (default: 1.0.0)"
                echo "  --base         Set base image"
                echo "  --tag          Set base tag"
                echo "  --help         Show this help"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
    
    # Run build steps
    check_prerequisites
    prepare_build
    build_image
    export_image
    push_image
    build_iso
    cleanup
    
    log ""
    log "================================="
    log "Build complete!"
    log "================================="
    log ""
    log "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    log "Output: ${OUTPUT_DIR}"
    log ""
    log "To install on a system:"
    log "  sudo bootc switch --transport containers-storage ${IMAGE_NAME}:${IMAGE_TAG}"
    log ""
    log "Or from registry:"
    log "  sudo bootc switch ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
    log ""
}

# Run main
main "$@"
