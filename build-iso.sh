#!/bin/bash
set -e

echo "======================================"
echo "   ChomiamOS ISO Builder"
echo "======================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    error "Do not run this script as root! Use sudo when needed."
fi

# Step 1: Check prerequisites
info "Checking prerequisites..."
if ! command -v mkarchiso &> /dev/null; then
    error "mkarchiso not found. Install archiso package."
fi

if ! command -v makepkg &> /dev/null; then
    error "makepkg not found. Install base-devel package."
fi

# Step 2: Build Calamares
info "Building Calamares from source..."
cd calamares-build

if [ ! -f "build-calamares.sh" ]; then
    error "build-calamares.sh not found!"
fi

bash build-calamares.sh || error "Failed to build Calamares"

cd "$SCRIPT_DIR"

# Step 3: Create package repository
info "Creating CHO package repository..."
cd cho-repo

if [ ! -f "create-repo.sh" ]; then
    error "create-repo.sh not found!"
fi

bash create-repo.sh || error "Failed to create repository"

# Step 4: Setup local repository for build
info "Setting up local repository for ISO build..."
REPO_PATH="$SCRIPT_DIR/cho-repo/x86_64"
if [ ! -d "$REPO_PATH" ]; then
    error "Repository directory not found: $REPO_PATH"
fi

# Create temporary pacman.conf with local repo
cd "$SCRIPT_DIR/archiso"
cp pacman.conf pacman.conf.bak

# Replace GitHub URL with local path temporarily
sed -i "s|Server = https://raw.githubusercontent.com/chomiam/cho/main/x86_64|Server = file://$REPO_PATH|g" pacman.conf

info "Temporary pacman.conf configured with local repository"

# Step 5: Clean previous builds
if [ -d "work" ]; then
    warn "Cleaning previous build directory..."
    sudo rm -rf work
fi

if [ -d "out" ]; then
    warn "Cleaning previous output directory..."
    sudo rm -rf out
fi

# Step 6: Build ISO
info "Building ISO... This may take a while..."
sudo mkarchiso -v -w work/ -o out/ . || {
    # Restore original pacman.conf on failure
    mv pacman.conf.bak pacman.conf
    error "Failed to build ISO"
}

# Restore original pacman.conf
mv pacman.conf.bak pacman.conf

# Step 7: Success
info "ISO built successfully!"
echo ""
echo "======================================"
echo "   Build Complete!"
echo "======================================"
echo ""
echo "ISO location: $(ls -1 out/*.iso)"
echo "ISO size: $(du -h out/*.iso | cut -f1)"
echo ""
echo "You can now:"
echo "  1. Test the ISO in a VM: qemu-system-x86_64 -cdrom out/*.iso -m 2048 -enable-kvm"
echo "  2. Write to USB: sudo dd if=out/*.iso of=/dev/sdX bs=4M status=progress oflag=sync"
echo "  3. Push to GitHub:"
echo "     cd cho-repo"
echo "     git add x86_64/"
echo "     git commit -m 'Add built packages'"
echo "     git push"
echo ""
