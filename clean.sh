#!/bin/bash
set -e

echo "======================================"
echo "   ChomiamOS Cleaner"
echo "======================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    error "Ne lancez PAS ce script en root! Le script demandera sudo quand nécessaire."
fi

# Validate sudo access
info "Validation des accès sudo..."
if ! sudo -v; then
    error "Accès sudo requis pour nettoyer"
fi

echo ""
warn "Ce script va supprimer:"
echo "  - archiso/work/"
echo "  - archiso/out/"
echo "  - archiso/pacman.conf.bak"
echo ""
info "NOTE: cho-repo/x86_64/ ne sera PAS supprimé (contient les paquets GitHub)"
echo ""

read -p "Continuer? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[YyOo]$ ]]; then
    info "Nettoyage annulé."
    exit 0
fi

echo ""
info "Début du nettoyage..."

# Clean archiso work directory
cd "$SCRIPT_DIR/archiso"

if [ -d "work" ]; then
    warn "Nettoyage de archiso/work/..."

    # Unmount any mounted filesystems
    if mountpoint -q work/x86_64/airootfs 2>/dev/null || findmnt work/x86_64/airootfs &>/dev/null; then
        info "Démontage des systèmes de fichiers..."
        sudo umount -R work/x86_64/airootfs 2>/dev/null || true
    fi

    # Check for remaining mounts
    if findmnt -R work &>/dev/null; then
        info "Démontage récursif de tous les points de montage..."
        findmnt -R work | tail -n +2 | awk '{print $1}' | tac | while read mount_point; do
            sudo umount "$mount_point" 2>/dev/null || true
        done
    fi

    sudo rm -rf work
    info "✓ archiso/work/ supprimé"
else
    info "archiso/work/ n'existe pas"
fi

# Clean archiso out directory
if [ -d "out" ]; then
    warn "Nettoyage de archiso/out/..."
    sudo rm -rf out
    info "✓ archiso/out/ supprimé"
else
    info "archiso/out/ n'existe pas"
fi

# Clean backup pacman.conf
if [ -f "pacman.conf.bak" ]; then
    warn "Suppression de pacman.conf.bak..."
    rm -f pacman.conf.bak
    info "✓ pacman.conf.bak supprimé"
else
    info "pacman.conf.bak n'existe pas"
fi

# NOTE: We do NOT clean cho-repo/x86_64/ because it contains packages from GitHub
# The build-iso.sh script uses the local repo from GitHub instead of rebuilding Calamares
info "cho-repo/x86_64/ préservé (contient les paquets du dépôt GitHub)"

echo ""
echo "======================================"
echo "   NETTOYAGE TERMINÉ!"
echo "======================================"
echo ""
info "Tous les fichiers temporaires et de build ont été supprimés."
info "Vous pouvez maintenant relancer: ./build-iso.sh"
echo ""
