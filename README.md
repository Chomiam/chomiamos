# ChomiamOS

ISO custom d'Arch Linux avec installateur Calamares et environnement KDE Plasma minimal.

## Caractéristiques

- Base Arch Linux
- Installateur Calamares (compilé depuis les sources)
- KDE Plasma Desktop minimal
- Firefox navigateur
- NetworkManager avec applet plasma-nm
- Outils système KDE (systemsettings, kscreen, etc.)
- Support complet UEFI et BIOS

## Structure du projet

```
chomiamos/
├── archiso/          # Configuration archiso personnalisée
│   ├── airootfs/     # Fichiers du système live
│   ├── pacman.conf   # Configuration pacman avec dépôt CHO
│   └── packages.x86_64 # Liste des paquets
├── calamares-build/  # PKGBUILD et compilation de Calamares
├── cho-repo/         # Dépôt de paquets personnalisés
├── build-iso.sh      # Script automatique de build
├── setup-github.sh   # Configuration des dépôts GitHub
└── README.md
```

## Prérequis

```bash
sudo pacman -S archiso base-devel git
```

## Installation et Configuration

### 1. Configurer les dépôts GitHub

Créez d'abord les deux dépôts sur GitHub :
- `https://github.com/chomiam/chomiamos` - Projet principal
- `https://github.com/chomiam/cho` - Dépôt de paquets

Puis exécutez :

```bash
./setup-github.sh
```

Ce script va :
- Configurer le dépôt git principal
- Initialiser le dépôt de paquets
- Créer les commits initiaux
- Vous guider pour le push

### 2. Construction de l'ISO

Méthode automatique (recommandée) :

```bash
./build-iso.sh
```

Méthode manuelle :

```bash
# 1. Compiler Calamares
cd calamares-build
./build-calamares.sh

# 2. Créer le dépôt de paquets
cd ../cho-repo
./create-repo.sh

# 3. Construire l'ISO
cd ../archiso
sudo mkarchiso -v -w work/ -o out/ .
```

### 3. Publier les paquets sur GitHub

```bash
cd cho-repo
git add x86_64/
git commit -m "Add Calamares package and repository database"
git push origin main
```

Une fois poussé, l'ISO pourra télécharger Calamares depuis :
`https://raw.githubusercontent.com/chomiam/cho/main/x86_64`

## Utilisation de l'ISO

### Tester dans QEMU

```bash
qemu-system-x86_64 -cdrom out/chomiamos-*.iso -m 2048 -enable-kvm
```

### Écrire sur USB

```bash
sudo dd if=out/chomiamos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### Boot

1. Démarrez depuis l'ISO/USB
2. Le système boot sur KDE Plasma
3. Lancez l'installateur ChomiamOS depuis le bureau ou via :
   ```bash
   chomiamos-installer
   ```

## Dépôt CHO

Le dépôt CHO contient les paquets personnalisés. Pour l'utiliser sur un système Arch existant :

```bash
# Ajouter à /etc/pacman.conf
[cho]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/chomiam/cho/main/x86_64

# Synchroniser
sudo pacman -Sy

# Installer Calamares
sudo pacman -S calamares-git
```

## Personnalisation

### Ajouter des paquets

Éditez `archiso/packages.x86_64` et ajoutez vos paquets.

### Modifier la configuration Calamares

Configuration dans `archiso/airootfs/etc/calamares/`

### Changer le branding

Modifiez `archiso/profiledef.sh` :
- `iso_name` : nom du fichier ISO
- `iso_label` : label du volume
- `iso_publisher` : information éditeur

## Dépôts GitHub

- Projet principal: https://github.com/chomiam/chomiamos
- Dépôt de paquets: https://github.com/chomiam/cho

## Licence

Ce projet est un dérivé d'Arch Linux. Consultez les licences individuelles des composants.

## Support

Pour signaler des bugs ou contribuer :
https://github.com/chomiam/chomiamos/issues
