#!/bin/bash
set -e

echo "==> Creating CHO package repository..."

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME="cho"
REPO_DB="cho.db.tar.gz"

cd "$REPO_DIR"

# Create repository directory structure
mkdir -p x86_64

# Move all packages to x86_64 directory
if ls *.pkg.tar.zst 1> /dev/null 2>&1; then
    mv *.pkg.tar.zst x86_64/
fi

# Create repository database
cd x86_64
if ls *.pkg.tar.zst 1> /dev/null 2>&1; then
    echo "==> Creating repository database..."
    repo-add "$REPO_DB" *.pkg.tar.zst
    echo "==> Repository created successfully!"
    echo "==> Packages in repository:"
    ls -lh *.pkg.tar.zst
else
    echo "==> No packages found. Build packages first."
    exit 1
fi

# Create README for the repo
cd "$REPO_DIR"
cat > README.md << 'EOF'
# CHO Repository

Custom package repository for ChomiamOS.

## Adding the repository to pacman

Add the following to `/etc/pacman.conf`:

```
[cho]
SigLevel = Optional TrustAll
Server = file:///path/to/cho-repo/x86_64
```

Or for remote access:

```
[cho]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/chomiam/cho/main/x86_64
```

Then run:

```bash
sudo pacman -Sy
```

## Packages

- calamares-git: Calamares installer built from source
EOF

echo "==> Repository structure created at: $REPO_DIR"
