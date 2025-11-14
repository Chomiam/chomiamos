#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="chomiamos"
iso_label="CHOMIAMOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="ChomiamOS <https://github.com/chomiam/chomiamos>"
iso_application="ChomiamOS Live/Rescue DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('uefi.grub')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/chomiamos-installer"]="0:0:755"
  ["/home/liveuser"]="1000:1000:755"
  ["/home/liveuser/.config"]="1000:1000:755"
  ["/home/liveuser/.config/autostart"]="1000:1000:755"
  ["/home/liveuser/Desktop"]="1000:1000:755"
)
