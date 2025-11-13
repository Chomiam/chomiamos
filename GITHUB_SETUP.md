# Configuration GitHub pour ChomiamOS

## Étape 1 : Créer les dépôts sur GitHub

Connectez-vous sur https://github.com et créez les deux dépôts suivants :

### Dépôt 1 : chomiamos (Projet principal)

1. Allez sur https://github.com/new
2. Nom du dépôt : `chomiamos`
3. Description : "Custom Arch Linux ISO with Calamares installer and KDE Plasma"
4. Public ou Private : **Public** (recommandé pour que le dépôt de paquets soit accessible)
5. Ne cochez PAS "Initialize this repository with a README"
6. Cliquez sur "Create repository"

### Dépôt 2 : cho (Dépôt de paquets)

1. Allez sur https://github.com/new
2. Nom du dépôt : `cho`
3. Description : "ChomiamOS custom package repository"
4. Public ou Private : **Public** (OBLIGATOIRE pour que pacman puisse télécharger les paquets)
5. Ne cochez PAS "Initialize this repository with a README"
6. Cliquez sur "Create repository"

## Étape 2 : Exécuter le script de configuration

Une fois les deux dépôts créés sur GitHub, exécutez :

```bash
cd /home/chomiam/chomiamos/chomiamos
./setup-github.sh
```

Le script va :
1. Configurer les remote git
2. Créer les fichiers .gitignore appropriés
3. Faire le commit initial
4. Vous demander de pousser vers GitHub

## Étape 3 : Authentification GitHub

Lors du premier push, GitHub vous demandera de vous authentifier.

### Option A : Personal Access Token (Recommandé)

1. Allez sur https://github.com/settings/tokens
2. Cliquez sur "Generate new token" > "Generate new token (classic)"
3. Donnez un nom : "ChomiamOS Development"
4. Cochez les permissions :
   - `repo` (toutes les sous-permissions)
5. Cliquez sur "Generate token"
6. **COPIEZ LE TOKEN IMMÉDIATEMENT** (vous ne pourrez plus le voir)
7. Lors du push, utilisez :
   - Username : `chomiam`
   - Password : **COLLEZ LE TOKEN**

### Option B : SSH Key

```bash
# Générer une clé SSH si vous n'en avez pas
ssh-keygen -t ed25519 -C "axel.valens@ik.me"

# Afficher la clé publique
cat ~/.ssh/id_ed25519.pub

# Copiez la sortie et ajoutez-la sur :
# https://github.com/settings/ssh/new

# Changez les URLs pour utiliser SSH
git remote set-url origin git@github.com:chomiam/chomiamos.git
cd cho-repo
git remote set-url origin git@github.com:chomiam/cho.git
```

## Étape 4 : Pousser le code

Après avoir configuré l'authentification :

```bash
# Pousser le projet principal
git push -u origin main

# Pousser le dépôt de paquets (après avoir build)
cd cho-repo
git push -u origin main
```

## Étape 5 : Vérification

Vérifiez que tout est en ligne :

1. Projet principal : https://github.com/chomiam/chomiamos
2. Dépôt de paquets : https://github.com/chomiam/cho

Le dépôt de paquets devrait contenir :
- `x86_64/` directory
- `README.md`
- `.gitignore`

## Workflow de développement

### Mise à jour du code

```bash
cd /home/chomiam/chomiamos/chomiamos
git add .
git commit -m "Description des changements"
git push
```

### Mise à jour des paquets

```bash
# 1. Rebuilder Calamares si nécessaire
cd calamares-build
./build-calamares.sh

# 2. Mettre à jour le dépôt
cd ../cho-repo
./create-repo.sh

# 3. Pousser sur GitHub
git add x86_64/
git commit -m "Update Calamares to version X.Y.Z"
git push
```

### Construction d'une nouvelle ISO

```bash
cd /home/chomiam/chomiamos/chomiamos
./build-iso.sh
```

## URL des ressources

Une fois tout configuré, vos utilisateurs pourront :

1. **Télécharger l'ISO** depuis les releases GitHub :
   https://github.com/chomiam/chomiamos/releases

2. **Utiliser le dépôt de paquets** en ajoutant à `/etc/pacman.conf` :
   ```ini
   [cho]
   SigLevel = Optional TrustAll
   Server = https://raw.githubusercontent.com/chomiam/cho/main/x86_64
   ```

3. **Cloner le projet** :
   ```bash
   git clone https://github.com/chomiam/chomiamos.git
   ```

## Troubleshooting

### Erreur : "remote origin already exists"

```bash
git remote set-url origin https://github.com/chomiam/chomiamos.git
```

### Erreur : "authentication failed"

Vérifiez que vous utilisez un token d'accès personnel ou une clé SSH valide.

### Erreur : "repository not found"

Vérifiez que vous avez bien créé les dépôts sur GitHub et qu'ils sont publics.

### Le dépôt CHO ne fonctionne pas

1. Vérifiez que le dépôt `cho` est **public**
2. Vérifiez que les fichiers sont bien dans `x86_64/` :
   - `*.pkg.tar.zst`
   - `cho.db.tar.gz`
   - `cho.files.tar.gz`
3. Testez l'URL manuellement :
   ```bash
   curl https://raw.githubusercontent.com/chomiam/cho/main/x86_64/cho.db.tar.gz
   ```

## Support

Pour toute question, ouvrez une issue sur :
https://github.com/chomiam/chomiamos/issues
