#!/bin/bash
# Auto-start script for live environment

# Enable services
systemctl enable sddm.service
systemctl enable NetworkManager.service

# Set default target to graphical
systemctl set-default graphical.target

# Create desktop shortcut for installer
mkdir -p /home/liveuser/Desktop
cat > /home/liveuser/Desktop/chomiamos-installer.desktop << 'DESKTOP_EOF'
[Desktop Entry]
Type=Application
Name=Install ChomiamOS
GenericName=System Installer
Comment=Install ChomiamOS to your computer
Exec=/usr/local/bin/chomiamos-installer
Icon=system-software-install
Terminal=false
Categories=System;
DESKTOP_EOF

chmod +x /home/liveuser/Desktop/chomiamos-installer.desktop
chown -R liveuser:liveuser /home/liveuser/Desktop
