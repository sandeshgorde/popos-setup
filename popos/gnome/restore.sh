#!/bin/bash
set -euo pipefail

BACKUP_DIR="$(cd "$(dirname "$0")" && pwd)/backups"
DCONF_DIR="$BACKUP_DIR/dconf"
EXT_DIR="$BACKUP_DIR/extensions"
WALLPAPER_DIR="$BACKUP_DIR/wallpaper"

echo "=== GNOME State Restore ==="

if [ ! -d "$DCONF_DIR" ]; then
  echo "  No backups found at $BACKUP_DIR"
  echo "  Run export.sh first or clone the repo with backups included."
  exit 1
fi

echo "  Restoring dconf settings..."
for f in "$DCONF_DIR"/*.dconf; do
  name=$(basename "$f" .dconf)
  echo "    Loading: $name"
  if [ "$name" = "full" ]; then
    dconf load / < "$f"
  else
    path="/${name//-/\/}/"
    dconf load "$path" < "$f" 2>/dev/null || true
  fi
done

echo "  Restoring wallpaper..."
WALL_SRC="$WALLPAPER_DIR/current-wallpaper.jpg"
if [ -f "$WALL_SRC" ]; then
  mkdir -p "$HOME/.local/share/backgrounds"
  cp "$WALL_SRC" "$HOME/.local/share/backgrounds/restored-wallpaper.jpg"
  gsettings set org.gnome.desktop.background picture-uri \
    "file://$HOME/.local/share/backgrounds/restored-wallpaper.jpg"
  gsettings set org.gnome.desktop.background picture-uri-dark \
    "file://$HOME/.local/share/backgrounds/restored-wallpaper.jpg"
  gsettings set org.gnome.desktop.screensaver picture-uri \
    "file://$HOME/.local/share/backgrounds/restored-wallpaper.jpg"
  echo "    Wallpaper restored"
fi

WALL_DARK_SRC="$WALLPAPER_DIR/current-wallpaper-dark.jpg"
if [ -f "$WALL_DARK_SRC" ] && [ ! -f "$WALL_SRC" ]; then
  mkdir -p "$HOME/.local/share/backgrounds"
  cp "$WALL_DARK_SRC" "$HOME/.local/share/backgrounds/restored-wallpaper-dark.jpg"
  gsettings set org.gnome.desktop.background picture-uri-dark \
    "file://$HOME/.local/share/backgrounds/restored-wallpaper-dark.jpg"
  echo "    Dark wallpaper restored"
fi

echo "  Restoring extension settings..."
for f in "$EXT_DIR"/settings-*.dconf; do
  if [ -f "$f" ]; then
    clean=$(basename "$f" .dconf | sed 's/^settings-//')
    dconf load "/org/gnome/shell/extensions/$clean/" < "$f" 2>/dev/null || true
  fi
done

echo ""
echo "  Extensions list saved at: $EXT_DIR/enabled.txt"
echo "  Install missing extensions via GNOME Extensions website or your distro's package manager."
echo "  Install the gnome-shell-extension-manager or use 'gnome-extensions-cli' for bulk install."

echo ""
echo "=== Restore complete ==="
echo "  Log out and back in for all changes to take effect."
