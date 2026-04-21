#!/bin/bash
# Fix GHCR installation issues

echo "=========================================="
echo "  Fix GHCR Installation"
echo "=========================================="
echo ""

# Check 1: Did you push the image?
echo "Did you already push the image to GHCR? (y/n)"
read -n 1 -r PUSHED
echo ""

if [[ ! $PUSHED =~ ^[Yy]$ ]]; then
    echo ""
    echo "You need to push the image first:"
    echo "  bash push-to-ghcr.sh"
    exit 0
fi

# Check 2: Verify with curl
echo ""
echo "Checking if image is accessible..."
if curl -s -o /dev/null -w "%{http_code}" https://ghcr.io/v2/kingsolarious/zephyrus-os/manifests/latest | grep -q "200"; then
    echo "✓ Image is publicly accessible"
else
    echo "✗ Image is NOT accessible (403/404)"
    echo ""
    echo "ACTION REQUIRED:"
    echo "1. Go to: https://github.com/users/Kingsolarious/packages"
    echo "2. Click on 'zephyrus-os'"
    echo "3. Click 'Package settings' (gear icon)"
    echo "4. Scroll to 'Danger Zone'"
    echo "5. Click 'Change visibility' → 'Public'"
    echo ""
    echo "OR login to pull private image:"
    echo "  echo YOUR_TOKEN | sudo podman login ghcr.io -u Kingsolarious --password-stdin"
fi

echo ""
echo "Alternative: Install from local image using skopeo"
echo "  sudo rpm-ostree rebase ostree-unverified-image:dir:/tmp/zephyrus-export"
