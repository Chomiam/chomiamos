#!/bin/bash
set -e

echo "======================================"
echo "   ChomiamOS ISO Builder (Simple)"
echo "======================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check prerequisites
info "Checking prerequisites..."
if ! command -v mkarchiso &> /dev/null; then
    error "mkarchiso not found. Install archiso package."
fi

# Validate sudo access
info "Checking sudo access..."
sudo -v || error "sudo access required"

# Clean previous builds
cd "$SCRIPT_DIR/archiso"

if [ -d "work" ]; then
    warn "Cleaning previous build directory..."
    sudo rm -rf work
fi

if [ -d "out" ]; then
    warn "Cleaning previous output directory..."
    sudo rm -rf out
fi

# Build ISO
info "Building ISO... This may take 15-30 minutes..."
info "Package installation phase may appear to hang - this is normal."
echo ""

sudo mkarchiso -v -w work/ -o out/ . || error "Failed to build ISO"

# Success
info "ISO built successfully!"
echo ""
echo "======================================"
echo "   Build Complete!"
echo "======================================"
echo ""
ISO_FILE=$(ls -1 out/*.iso 2>/dev/null | head -n1)
if [ -f "$ISO_FILE" ]; then
    echo "ISO location: $ISO_FILE"
    echo "ISO size: $(du -h "$ISO_FILE" | cut -f1)"
    echo ""
    echo "You can now test the ISO:"
    echo "  qemu-system-x86_64 -cdrom \"$ISO_FILE\" -m 4096 -enable-kvm -boot d"
else
    warn "ISO file not found in out/ directory"
fi
echo ""
