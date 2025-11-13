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
