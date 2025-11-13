# ChomiamOS - Instructions de Build

## ✅ Dépôts GitHub créés

Les deux dépôts ont été créés et le code a été poussé :

1. **Projet principal** : https://github.com/Chomiam/chomiamos
2. **Dépôt de paquets** : https://github.com/Chomiam/cho

## 📋 Prochaines étapes

### Étape 1 : Compiler Calamares

```bash
cd /home/chomiam/chomiamos/chomiamos/calamares-build
./build-calamares.sh
```

⏱️ Temps estimé : 20-40 minutes
💾 Espace requis : ~200 MB

Cette étape va :
- Cloner le dépôt Calamares depuis GitHub
- Installer toutes les dépendances nécessaires
- Compiler Calamares avec CMake
- Créer le paquet `.pkg.tar.zst`
- Le déplacer dans `cho-repo/`

### Étape 2 : Créer le dépôt de paquets

```bash
cd ../cho-repo
./create-repo.sh
```

⏱️ Temps : < 1 minute

Cette étape va :
- Créer la structure `x86_64/`
- Générer la base de données du dépôt
- Créer `cho.db.tar.gz` et `cho.files.tar.gz`

### Étape 3 : Publier les paquets sur GitHub

```bash
git add x86_64/
git commit -m "Add Calamares $(date +%Y-%m-%d)"
git push origin main
```

⏱️ Temps : < 1 minute

### Étape 4 : Vérifier que le dépôt est accessible

```bash
curl -I https://raw.githubusercontent.com/Chomiam/cho/main/x86_64/cho.db.tar.gz
```

Vous devriez voir : `HTTP/2 200 OK`

### Étape 5 : Construire l'ISO

Méthode automatique (recommandée) :

```bash
cd /home/chomiam/chomiamos/chomiamos
./build-iso.sh
```

OU méthode manuelle :

```bash
cd archiso
sudo mkarchiso -v -w work/ -o out/ .
```

⏱️ Temps estimé : 10-30 minutes
💾 Taille de l'ISO : ~1.5-2 GB

### Étape 6 : Tester l'ISO

```bash
# Avec QEMU (recommandé pour test rapide)
qemu-system-x86_64 \
  -cdrom archiso/out/chomiamos-*.iso \
  -m 2048 \
  -enable-kvm \
  -cpu host \
  -smp 2

# Sur clé USB (remplacez /dev/sdX par votre clé)
sudo dd if=archiso/out/chomiamos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## 🎯 Contenu de l'ISO

Votre ISO ChomiamOS contient :

**Base système :**
- Arch Linux avec kernel et firmware
- Outils système de base
- Support UEFI et BIOS

**Interface graphique :**
- KDE Plasma Desktop (configuration minimale)
- SDDM (gestionnaire de connexion)
- Firefox navigateur web
- Konsole, Dolphin, Kate

**Outils système KDE :**
- systemsettings (paramètres système complets)
- kscreen (gestion des écrans et résolution)
- plasma-nm (applet WiFi/réseau)
- plasma-pa (gestion audio)
- powerdevil (gestion énergie)
- bluedevil (Bluetooth)

**Installateur :**
- Calamares (compilé depuis les sources)
- Configuration personnalisée ChomiamOS
- Support partitionnement, utilisateurs, bootloader

**Réseau :**
- NetworkManager
- Support WiFi complet
- Configuration graphique réseau

## 🔧 Personnalisation

### Ajouter des paquets

Éditez `archiso/packages.x86_64` :

```bash
nano archiso/packages.x86_64
```

Ajoutez les paquets désirés, un par ligne.

### Modifier la configuration Calamares

Configuration dans :
- `archiso/airootfs/etc/calamares/settings.conf` - Configuration générale
- `archiso/airootfs/etc/calamares/modules/` - Configuration des modules

### Changer le branding

Éditez `archiso/profiledef.sh` :

```bash
iso_name="votre-nom"
iso_label="VOTRE_LABEL"
iso_publisher="Votre Nom"
```

## 📊 Espace disque requis

- Sources Calamares : ~50 MB
- Build Calamares : ~200 MB
- Package Calamares : ~10 MB
- Build ISO (work/) : ~3-4 GB
- ISO finale : ~1.5-2 GB
- **Total recommandé : 10 GB libres**

## 🐛 Dépannage

### Erreur : "Package calamares-git not found"

Le dépôt CHO n'est pas accessible. Vérifiez :

```bash
# Test 1 : Le dépôt est-il public ?
curl -I https://github.com/Chomiam/cho

# Test 2 : Les paquets sont-ils poussés ?
curl -I https://raw.githubusercontent.com/Chomiam/cho/main/x86_64/cho.db.tar.gz

# Test 3 : Le pacman.conf pointe-t-il vers la bonne URL ?
grep -A2 "\[cho\]" archiso/pacman.conf
```

### Erreur de compilation Calamares

```bash
# Installer les dépendances manquantes
sudo pacman -S --needed base-devel cmake extra-cmake-modules qt6-base qt6-tools kpmcore

# Nettoyer et recommencer
cd calamares-build
rm -rf calamares src pkg
./build-calamares.sh
```

### ISO trop volumineuse

Retirez des paquets dans `archiso/packages.x86_64` :
- Commentez les sections non essentielles
- Retirez les pilotes matériel non nécessaires

### Manque d'espace disque

```bash
# Nettoyer les builds précédents
cd archiso
sudo rm -rf work/ out/

# Nettoyer le cache pacman
sudo pacman -Scc
```

## 📚 Ressources

- **Documentation Archiso** : https://wiki.archlinux.org/title/Archiso
- **Documentation Calamares** : https://github.com/calamares/calamares/wiki
- **Projet ChomiamOS** : https://github.com/Chomiam/chomiamos
- **Dépôt CHO** : https://github.com/Chomiam/cho

## 🚀 Build automatique complet

Si vous voulez tout faire en une commande :

```bash
cd /home/chomiam/chomiamos/chomiamos
./build-iso.sh
```

Ce script :
1. ✅ Compile Calamares
2. ✅ Crée le dépôt CHO
3. ✅ Configure pacman.conf temporairement en local
4. ✅ Build l'ISO
5. ✅ Nettoie et restaure la config

**Note** : N'oubliez pas de pousser les paquets sur GitHub après le premier build !

```bash
cd cho-repo
git add x86_64/
git commit -m "Add built packages"
git push
```

## ⚡ Commandes rapides

```bash
# Build complet
./build-iso.sh

# Test QEMU
qemu-system-x86_64 -cdrom archiso/out/*.iso -m 2048 -enable-kvm

# Créer checksum
sha256sum archiso/out/*.iso > archiso/out/chomiamos.sha256

# Upload ISO (exemple avec scp)
scp archiso/out/*.iso user@server:/path/

# Créer une release GitHub
gh release create v1.0 archiso/out/*.iso --title "ChomiamOS v1.0" --notes "First release"
```

Bon build ! 🎉
