#!/bin/bash
set -e

echo "==> Using Calamares from AUR (already built)..."

# Check if package exists in cho-repo/x86_64
if ls ../cho-repo/x86_64/calamares-git-*.pkg.tar.zst 1> /dev/null 2>&1; then
    echo "==> Calamares package found in cho-repo/x86_64!"
    echo "==> Calamares ready!"
else
    # If not found in x86_64, check if it's in the root and needs to be moved
    if ls ../cho-repo/calamares-git-*.pkg.tar.zst 1> /dev/null 2>&1; then
        echo "==> Moving Calamares package to cho-repo directory for processing..."
        # The create-repo.sh script will move it to x86_64
        echo "==> Calamares ready!"
    else
        echo "==> Error: Calamares package not found"
        exit 1
    fi
fi
