# ChomiamOS - Guide de démarrage rapide

Ce guide vous permet de créer votre première ISO ChomiamOS en quelques étapes.

## Prérequis

```bash
# Installer les outils nécessaires
sudo pacman -S archiso base-devel git
```

## Étapes rapides

### 1. Configurer GitHub (5 minutes)

Suivez les instructions détaillées dans [GITHUB_SETUP.md](GITHUB_SETUP.md)

**En résumé :**
1. Créez `https://github.com/chomiam/chomiamos` (public)
2. Créez `https://github.com/chomiam/cho` (public - IMPORTANT)
3. Exécutez `./setup-github.sh`
4. Poussez le code initial

### 2. Option A : Build complet (automatique)

```bash
./build-iso.sh
```

Cela va :
- Compiler Calamares depuis GitHub
- Créer le dépôt de paquets CHO
- Construire l'ISO complète

⏱️ Temps estimé : 30-60 minutes (selon votre machine)

### 2. Option B : Build étape par étape (manuel)

#### Étape 2.1 : Compiler Calamares

```bash
cd calamares-build
./build-calamares.sh
```

⏱️ Temps : 20-40 minutes

#### Étape 2.2 : Créer le dépôt de paquets

```bash
cd ../cho-repo
./create-repo.sh
```

⏱️ Temps : < 1 minute

#### Étape 2.3 : Publier sur GitHub

```bash
git add x86_64/
git commit -m "Add Calamares package"
git push origin main
```

Vérifiez que c'est accessible :
```bash
curl -I https://raw.githubusercontent.com/chomiam/cho/main/x86_64/cho.db.tar.gz
```

Vous devriez voir `HTTP/2 200`

#### Étape 2.4 : Construire l'ISO

```bash
cd ../archiso
sudo mkarchiso -v -w work/ -o out/ .
```

⏱️ Temps : 10-20 minutes

### 3. Tester l'ISO

```bash
# Avec QEMU
qemu-system-x86_64 -cdrom archiso/out/chomiamos-*.iso -m 2048 -enable-kvm

# Sur USB (ATTENTION : remplacez sdX par votre clé USB !)
sudo dd if=archiso/out/chomiamos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Contenu de l'ISO

Votre ISO ChomiamOS contient :

✅ Arch Linux base
✅ Kernel Linux avec firmware
✅ KDE Plasma Desktop (minimal)
✅ Firefox
✅ Calamares installer
✅ NetworkManager + plasma-nm (applet WiFi)
✅ Outils système KDE :
   - systemsettings (paramètres système)
   - kscreen (configuration écran)
   - powerdevil (gestion énergie)
   - breeze (thème)
✅ Outils de base (konsole, dolphin, kate)

## Utilisation de l'ISO

1. **Boot** : L'ISO démarre automatiquement sur KDE Plasma
2. **Réseau** : Cliquez sur l'icône réseau pour vous connecter au WiFi
3. **Installation** : Double-cliquez sur "Install ChomiamOS" sur le bureau ou lancez :
   ```bash
   chomiamos-installer
   ```

## Workflow de développement

### Ajouter des paquets

Éditez `archiso/packages.x86_64` :

```bash
nano archiso/packages.x86_64
```

Ajoutez vos paquets, puis rebuild l'ISO :

```bash
./build-iso.sh
```

### Mettre à jour Calamares

```bash
cd calamares-build
rm -rf calamares  # Supprimer l'ancien clone
./build-calamares.sh
cd ../cho-repo
./create-repo.sh
git add x86_64/
git commit -m "Update Calamares"
git push
```

Puis rebuild l'ISO.

### Personnaliser Calamares

Configuration dans `archiso/airootfs/etc/calamares/` :
- `settings.conf` : Configuration générale
- `modules/` : Configuration des modules

### Changer le branding

Éditez `archiso/profiledef.sh` :

```bash
iso_name="votre-nom"
iso_label="VOTRE_LABEL"
iso_publisher="Votre Nom <email@example.com>"
```

## Structure des fichiers

```
chomiamos/
├── archiso/
│   ├── airootfs/              # Fichiers copiés dans l'ISO
│   │   ├── etc/
│   │   │   ├── calamares/     # Config Calamares
│   │   │   └── systemd/       # Services systemd
│   │   ├── root/
│   │   │   └── .automated_script.sh  # Script auto-démarrage
│   │   └── usr/local/bin/
│   │       └── chomiamos-installer   # Lanceur installer
│   ├── pacman.conf            # Config pacman (avec dépôt CHO)
│   ├── packages.x86_64        # Liste des paquets
│   └── profiledef.sh          # Configuration ISO
├── calamares-build/
│   ├── PKGBUILD               # Build Calamares
│   └── build-calamares.sh     # Script de compilation
├── cho-repo/
│   ├── x86_64/                # Paquets compilés + DB
│   └── create-repo.sh         # Script création dépôt
├── build-iso.sh               # Build automatique complet
├── setup-github.sh            # Configuration GitHub
├── README.md                  # Documentation principale
├── GITHUB_SETUP.md            # Guide GitHub détaillé
└── QUICKSTART.md              # Ce fichier
```

## Tailles approximatives

- **Compilation Calamares** : ~200 MB (sources + build)
- **Package Calamares** : ~10 MB
- **ISO finale** : ~1.5-2 GB (selon les paquets ajoutés)
- **RAM recommandée pour build** : 4 GB minimum
- **Espace disque requis** : 10 GB minimum

## Troubleshooting

### "ERROR: Package X not found"

Le paquet n'existe pas ou est mal orthographié dans `packages.x86_64`.

```bash
# Chercher le bon nom
pacman -Ss nom-du-paquet
```

### "Failed to retrieve calamares-git"

Le dépôt CHO n'est pas accessible :

1. Vérifiez qu'il est public
2. Vérifiez que les paquets sont poussés sur GitHub
3. Testez manuellement :
   ```bash
   curl https://raw.githubusercontent.com/chomiam/cho/main/x86_64/cho.db.tar.gz
   ```

### "No space left on device"

Libérez de l'espace ou nettoyez les builds précédents :

```bash
cd archiso
sudo rm -rf work/ out/
```

### "mkarchiso: command not found"

```bash
sudo pacman -S archiso
```

### Build très lent

La compilation de Calamares est longue. Options :

1. Utilisez un CPU plus puissant
2. Augmentez le nombre de threads make :
   ```bash
   # Dans calamares-build/build-calamares.sh
   makepkg -sf --noconfirm -j$(nproc)
   ```
3. Compilez une seule fois, puis réutilisez le paquet

## Commandes utiles

```bash
# Voir la taille de l'ISO
du -h archiso/out/*.iso

# Voir les logs de build
less archiso/work/build.log

# Lister les paquets dans l'ISO
unsquashfs -l archiso/work/x86_64/airootfs/airootfs.sfs | less

# Tester l'ISO avec plus de RAM
qemu-system-x86_64 -cdrom archiso/out/*.iso -m 4096 -enable-kvm

# Créer un checksum de l'ISO
sha256sum archiso/out/*.iso > archiso/out/chomiamos.sha256
```

## Prochaines étapes

- Ajoutez votre propre branding/logo
- Créez des configurations Calamares personnalisées
- Ajoutez vos propres paquets au dépôt CHO
- Créez des releases GitHub avec l'ISO
- Automatisez le build avec GitHub Actions

## Support

- Documentation complète : [README.md](README.md)
- Configuration GitHub : [GITHUB_SETUP.md](GITHUB_SETUP.md)
- Issues : https://github.com/chomiam/chomiamos/issues
- Arch Wiki : https://wiki.archlinux.org/title/Archiso

Bon build ! 🚀
