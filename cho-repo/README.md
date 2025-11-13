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

Après avoir construit de nouveaux paquets :

```bash
git add x86_64/
git commit -m "Update packages"
git push
```

## Structure

```
cho/
├── x86_64/           # Paquets et base de données du dépôt
│   ├── *.pkg.tar.zst # Paquets compilés
│   ├── cho.db.tar.gz # Base de données du dépôt
│   └── cho.files.tar.gz # Index des fichiers
├── create-repo.sh    # Script de création du dépôt
└── README.md
```

## Lien avec le projet principal

Ce dépôt fait partie du projet ChomiamOS :
https://github.com/chomiam/chomiamos

## Contribution

Pour ajouter de nouveaux paquets :

1. Créez un PKGBUILD dans le projet principal
2. Compilez avec `makepkg -sf`
3. Déplacez le paquet dans `cho-repo/`
4. Exécutez `./create-repo.sh`
5. Poussez sur GitHub

## Support

Issues : https://github.com/chomiam/chomiamos/issues
