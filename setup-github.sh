#!/bin/bash
set -e

echo "==> ChomiamOS GitHub Setup"
echo "=========================="
echo ""

GITHUB_USER="chomiam"
PROJECT_REPO="chomiamos"
PACKAGES_REPO="cho"

echo "This script will help you set up the GitHub repositories for ChomiamOS."
echo ""
echo "You need to create two repositories on GitHub:"
echo "  1. https://github.com/${GITHUB_USER}/${PROJECT_REPO} - Main project"
echo "  2. https://github.com/${GITHUB_USER}/${PACKAGES_REPO} - Package repository"
echo ""
echo "Press Enter when you have created these repositories..."
read

# Initialize main project repository
echo "==> Setting up main project repository..."
git remote add origin "https://github.com/${GITHUB_USER}/${PROJECT_REPO}.git" 2>/dev/null || \
    git remote set-url origin "https://github.com/${GITHUB_USER}/${PROJECT_REPO}.git"

# Create .gitignore
cat > .gitignore << 'EOF'
# Build artifacts
archiso/work/
archiso/out/
calamares-build/calamares/
calamares-build/src/
calamares-build/pkg/
calamares-build/*.pkg.tar.zst
cho-repo/x86_64/*.pkg.tar.zst
cho-repo/x86_64/*.db*
cho-repo/x86_64/*.files*

# Temporary files
*.log
*~
.*.swp
EOF

# Create initial commit
git add .
git commit -m "Initial commit: ChomiamOS project structure

- Added archiso configuration with custom packages
- Added Calamares PKGBUILD from source
- Added CHO repository structure
- Configured KDE Plasma minimal desktop
- Integrated CHO repository in pacman.conf" || true

git branch -M main
git push -u origin main

echo ""
echo "==> Main repository configured!"
echo ""
echo "==> Now setting up package repository..."
echo ""

# Setup cho-repo as a separate repository
cd cho-repo

# Initialize git if not already done
if [ ! -d .git ]; then
    git init
fi

git remote add origin "https://github.com/${GITHUB_USER}/${PACKAGES_REPO}.git" 2>/dev/null || \
    git remote set-url origin "https://github.com/${GITHUB_USER}/${PACKAGES_REPO}.git"

# Create README for cho repo
cat > README.md << 'EOF'
# CHO - ChomiamOS Package Repository

Repository de paquets personnalisés pour ChomiamOS.

## Utilisation

Ajoutez à votre `/etc/pacman.conf` :

```ini
[cho]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/chomiam/cho/main/x86_64
```

Puis :

```bash
sudo pacman -Sy
```

## Paquets disponibles

- **calamares-git**: Installateur Calamares compilé depuis les sources GitHub

## Construction des paquets

Les paquets sont construits dans le projet principal chomiamos :

```bash
cd calamares-build
./build-calamares.sh
cd ../cho-repo
./create-repo.sh
```

## Mise à jour du dépôt

```bash
git add x86_64/
git commit -m "Update packages"
git push
```
EOF

# Create .gitignore for cho-repo
cat > .gitignore << 'EOF'
# Keep only the built packages and db
!x86_64/
x86_64/*
!x86_64/*.pkg.tar.zst
!x86_64/*.db*
!x86_64/*.files*
EOF

# Create x86_64 directory structure
mkdir -p x86_64

# Create placeholder if no packages yet
if [ ! -f x86_64/.gitkeep ]; then
    touch x86_64/.gitkeep
    echo "Note: Build packages first before pushing to GitHub"
fi

git add .
git commit -m "Initial commit: CHO repository structure" || true
git branch -M main

echo ""
echo "==> Package repository configured!"
echo ""
echo "To push the package repository:"
echo "  cd cho-repo"
echo "  git push -u origin main"
echo ""
echo "==> GitHub Setup Complete!"
echo ""
echo "Next steps:"
echo "  1. Build Calamares: cd calamares-build && ./build-calamares.sh"
echo "  2. Create repository: cd ../cho-repo && ./create-repo.sh"
echo "  3. Push packages: git add x86_64/ && git commit -m 'Add packages' && git push"
echo "  4. Build ISO: cd ../archiso && sudo mkarchiso -v -w work/ -o out/ ."
echo ""
