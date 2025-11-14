#!/bin/bash
set -e

echo "==> Checking for Calamares package..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if package already exists in cho-repo/x86_64 (from GitHub)
if ls ../cho-repo/x86_64/calamares-git-*.pkg.tar.zst 1> /dev/null 2>&1; then
    echo "==> Calamares package found in cho-repo/x86_64!"
    echo "==> Using existing package from GitHub repository."
    exit 0
fi

# Check if package exists in cho-repo root
if ls ../cho-repo/calamares-git-*.pkg.tar.zst 1> /dev/null 2>&1; then
    echo "==> Calamares package found in cho-repo root!"
    echo "==> It will be moved to x86_64/ by create-repo.sh"
    exit 0
fi

# If we get here, the package is missing - this shouldn't happen if GitHub repo is cloned
echo "==> WARNING: Calamares package not found!"
echo "==> Make sure you have cloned the cho repository with:"
echo "    cd cho-repo && git pull"
echo ""
echo "==> Or build it manually from AUR:"
echo "    cd calamares-build"
echo "    makepkg -sf"
echo "    mv calamares-git-*.pkg.tar.zst ../cho-repo/"
exit 1
