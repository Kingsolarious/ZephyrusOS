#!/bin/bash
# Push to Docker Hub as fallback

echo "=========================================="
echo "  Push to Docker Hub (Fallback)"
echo "=========================================="
echo ""

echo "1. Create account at https://hub.docker.com"
echo "2. Create access token at https://hub.docker.com/settings/security"
echo ""
read -p "Docker Hub username: " DH_USER
read -sp "Access token: " DH_TOKEN
echo ""

# Login
echo "$DH_TOKEN" | podman login docker.io -u "$DH_USER" --password-stdin

# Tag and push
podman tag zephyrus-os:local docker.io/$DH_USER/zephyrus-os:latest
podman push docker.io/$DH_USER/zephyrus-os:latest

echo ""
echo "Now install with:"
echo "  sudo rpm-ostree rebase ostree-unverified-registry:docker.io/$DH_USER/zephyrus-os:latest"
