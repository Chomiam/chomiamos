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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Setup logging
LOG_DIR="$SCRIPT_DIR/logs"
BUILD_DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/build_${BUILD_DATE}.log"

# Clean old logs (keep only the last one if exists)
if [ -d "$LOG_DIR" ]; then
    rm -rf "$LOG_DIR"
fi
mkdir -p "$LOG_DIR"

# Logging function
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_only() {
    echo "$1" >> "$LOG_FILE"
}

error() {
    local msg="${RED}[ERROR]${NC} $1"
    echo -e "$msg"
    echo "[ERROR] $1" >> "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "======================================"  | tee -a "$LOG_FILE"
    echo "   BUILD ÉCHOUÉ"  | tee -a "$LOG_FILE"
    echo "======================================"  | tee -a "$LOG_FILE"
    echo ""  | tee -a "$LOG_FILE"
    echo "📋 Logs disponibles dans: $LOG_FILE"  | tee -a "$LOG_FILE"
    echo ""  | tee -a "$LOG_FILE"
    exit 1
}

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    log_only "[INFO] $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    log_only "[WARN] $1"
}

step() {
    echo -e "${BLUE}[STEP]${NC} $1"
    log_only "[STEP] $1"
}

# Record start time
BUILD_START=$(date +%s)

log "======================================"
log "ChomiamOS ISO Builder"
log "Build started: $(date)"
log "======================================"
log ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    error "Ne lancez PAS ce script en root! Le script demandera sudo quand nécessaire."
fi

# Validate sudo access at the beginning
step "Validation des accès sudo..."
info "Vous allez être invité à entrer votre mot de passe sudo UNE FOIS au début."
echo ""

if ! sudo -v; then
    error "Accès sudo requis pour construire l'ISO"
fi

info "✓ Accès sudo validé"
echo ""

# Keep sudo alive in background
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_REFRESH_PID=$!

# Cleanup function to kill sudo refresh
cleanup() {
    kill $SUDO_REFRESH_PID 2>/dev/null || true
}
trap cleanup EXIT

# Step 1: Check prerequisites
step "1/6 - Vérification des prérequis..."
if ! command -v mkarchiso &> /dev/null; then
    error "mkarchiso introuvable. Installez le paquet archiso: sudo pacman -S archiso"
fi

if ! command -v makepkg &> /dev/null; then
    error "makepkg introuvable. Installez base-devel: sudo pacman -S base-devel"
fi

if ! command -v repo-add &> /dev/null; then
    error "repo-add introuvable. Installez pacman: sudo pacman -S pacman"
fi

info "✓ Tous les prérequis sont installés"
echo ""

# Step 2: Build Calamares
step "2/6 - Construction de Calamares..."
cd calamares-build

if [ ! -f "build-calamares.sh" ]; then
    error "build-calamares.sh introuvable!"
fi

bash build-calamares.sh 2>&1 | tee -a "$LOG_FILE" || error "Échec de la construction de Calamares"

cd "$SCRIPT_DIR"
info "✓ Calamares prêt"
echo ""

# Step 3: Create package repository
step "3/6 - Création du dépôt de paquets CHO..."
cd cho-repo

if [ ! -f "create-repo.sh" ]; then
    error "create-repo.sh introuvable!"
fi

bash create-repo.sh 2>&1 | tee -a "$LOG_FILE" || error "Échec de la création du dépôt"

cd "$SCRIPT_DIR"
info "✓ Dépôt CHO créé"
echo ""

# Step 4: Setup local repository for build
step "4/6 - Configuration du dépôt local pour le build..."
REPO_PATH="$SCRIPT_DIR/cho-repo/x86_64"
if [ ! -d "$REPO_PATH" ]; then
    error "Répertoire du dépôt introuvable: $REPO_PATH"
fi

# Navigate to archiso directory
cd "$SCRIPT_DIR/archiso"

# Backup original pacman.conf
if [ -f "pacman.conf.bak" ]; then
    warn "Restauration de pacman.conf depuis la sauvegarde précédente..."
    mv pacman.conf.bak pacman.conf
fi

cp pacman.conf pacman.conf.bak

# Replace GitHub URL with local path temporarily
sed -i "s|Server = https://raw.githubusercontent.com/[Cc]homiam/cho/main/x86_64|Server = file://$REPO_PATH|g" pacman.conf

info "✓ pacman.conf configuré avec le dépôt local"
echo ""

# Step 5: Clean previous builds
step "5/6 - Nettoyage des builds précédents..."

# Clean work directory with proper permissions handling
if [ -d "work" ]; then
    warn "Nettoyage du répertoire work/..."
    # First try to unmount any mounted filesystems
    if mountpoint -q work/x86_64/airootfs 2>/dev/null || findmnt work/x86_64/airootfs &>/dev/null; then
        info "Démontage des systèmes de fichiers montés..."
        sudo umount -R work/x86_64/airootfs 2>/dev/null || true
    fi
    # Check for any remaining mounts in work directory
    if findmnt -R work &>/dev/null; then
        info "Démontage récursif de tous les points de montage dans work/..."
        findmnt -R work | tail -n +2 | awk '{print $1}' | tac | while read mount_point; do
            sudo umount "$mount_point" 2>/dev/null || true
        done
    fi
    sudo rm -rf work 2>&1 | tee -a "$LOG_FILE"
    info "✓ Répertoire work/ nettoyé"
fi

# Clean out directory
if [ -d "out" ]; then
    warn "Nettoyage du répertoire out/..."
    sudo rm -rf out 2>&1 | tee -a "$LOG_FILE"
    info "✓ Répertoire out/ nettoyé"
fi

echo ""

# Step 6: Build ISO
step "6/6 - Construction de l'ISO..."
info "Ceci peut prendre 15-30 minutes selon votre machine..."
info "L'installation des paquets peut sembler figée - c'est normal."
echo ""

sudo mkarchiso -v -w work/ -o out/ . 2>&1 | tee -a "$LOG_FILE" || {
    # Restore original pacman.conf on failure
    warn "Échec du build, restauration de pacman.conf..."
    mv pacman.conf.bak pacman.conf
    error "Échec de la construction de l'ISO"
}

# Restore original pacman.conf
info "Restauration de pacman.conf..."
mv pacman.conf.bak pacman.conf

# Calculate build time
BUILD_END=$(date +%s)
BUILD_DURATION=$((BUILD_END - BUILD_START))
BUILD_MINUTES=$((BUILD_DURATION / 60))
BUILD_SECONDS=$((BUILD_DURATION % 60))

# Collect statistics
echo "" | tee -a "$LOG_FILE"
echo "======================================" | tee -a "$LOG_FILE"
echo "   BUILD RÉUSSI!" | tee -a "$LOG_FILE"
echo "======================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

ISO_FILE=$(ls -1 out/*.iso 2>/dev/null | head -n1)
if [ -f "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    PACKAGE_COUNT=$(wc -l < packages.x86_64)
    SQUASHFS_SIZE=$(du -h work/x86_64/airootfs/airootfs.sfs 2>/dev/null | cut -f1 || echo "N/A")

    echo "📀 Emplacement de l'ISO: $ISO_FILE" | tee -a "$LOG_FILE"
    echo "📊 Taille de l'ISO: $ISO_SIZE" | tee -a "$LOG_FILE"
    echo "📦 Nombre de paquets: $PACKAGE_COUNT" | tee -a "$LOG_FILE"
    echo "⏱️  Temps de build: ${BUILD_MINUTES}m ${BUILD_SECONDS}s" | tee -a "$LOG_FILE"
    echo "📋 Logs: $LOG_FILE" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
else
    warn "Fichier ISO introuvable dans out/"
    log_only "Fichier ISO introuvable dans out/"
fi

log "======================================"
log "Build completed: $(date)"
log "======================================"

echo "======================================"
