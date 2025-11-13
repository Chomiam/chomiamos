#!/bin/bash
set -e

echo "==> Building Calamares from source..."

# Install build dependencies
echo "==> Installing build dependencies..."
sudo pacman -S --needed --noconfirm \
    base-devel \
    cmake \
    extra-cmake-modules \
    qt6-base \
    qt6-declarative \
    qt6-svg \
    qt6-tools \
    qt6-translations \
    kconfig \
    kcoreaddons \
    kcrash \
    kdbusaddons \
    ki18n \
    kiconthemes \
    kio \
    kparts \
    kpmcore \
    kservice \
    kwidgetsaddons \
    libpwquality \
    polkit-qt6 \
    solid \
    boost \
    yaml-cpp \
    icu \
    hwdata \
    squashfs-tools \
    git

# Build the package
echo "==> Building package..."
makepkg -sf --noconfirm

# Move package to cho-repo
echo "==> Moving package to cho-repo..."
mv *.pkg.tar.zst ../cho-repo/

echo "==> Calamares built successfully!"
