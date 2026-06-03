#!/bin/bash

echo "Restoring configs..."

# ---- Dotfiles ----
echo "Restoring shell configs..."
cp -r dotfiles/. ~/

# ---- GNOME Settings ----
echo "Restoring GNOME settings..."
bash popos/gnome/restore.sh

# ---- keyd config ----
echo "Restoring keyd..."
sudo cp configs/keyd/default.conf /etc/keyd/default.conf
sudo systemctl restart keyd

# ---- Sublime Text ----
echo "Restoring Sublime config..."
mkdir -p ~/.config/sublime-text
cp -r sublime/config/* ~/.config/sublime-text/

echo "✅ Config restore complete!"


