#!/bin/bash
set -euo pipefail

BACKUP_DIR="$(cd "$(dirname "$0")" && pwd)/backups"
DCONF_DIR="$BACKUP_DIR/dconf"
EXT_DIR="$BACKUP_DIR/extensions"
WALLPAPER_DIR="$BACKUP_DIR/wallpaper"

echo "=== GNOME State Export ==="

mkdir -p "$DCONF_DIR" "$EXT_DIR" "$WALLPAPER_DIR"

echo "  Exporting dconf categories..."

dconf dump / > "$DCONF_DIR/full.dconf"
dconf dump /org/gnome/desktop/interface/ > "$DCONF_DIR/interface.dconf"
dconf dump /org/gnome/desktop/background/ > "$DCONF_DIR/background.dconf"
dconf dump /org/gnome/desktop/screensaver/ > "$DCONF_DIR/screensaver.dconf"
dconf dump /org/gnome/desktop/wm/preferences/ > "$DCONF_DIR/wm-preferences.dconf"
dconf dump /org/gnome/desktop/wm/keybindings/ > "$DCONF_DIR/wm-keybindings.dconf"
dconf dump /org/gnome/shell/keybindings/ > "$DCONF_DIR/shell-keybindings.dconf"
dconf dump /org/gnome/mutter/ > "$DCONF_DIR/mutter.dconf"
dconf dump /org/gnome/mutter/keybindings/ > "$DCONF_DIR/mutter-keybindings.dconf"
dconf dump /org/gnome/desktop/peripherals/ > "$DCONF_DIR/peripherals.dconf"
dconf dump /org/gnome/desktop/sound/ > "$DCONF_DIR/sound.dconf"
dconf dump /org/gnome/desktop/privacy/ > "$DCONF_DIR/privacy.dconf"
dconf dump /org/gnome/desktop/search-providers/ > "$DCONF_DIR/search-providers.dconf"
dconf dump /org/gnome/desktop/app-folders/ > "$DCONF_DIR/app-folders.dconf"
dconf dump /org/gnome/shell/ > "$DCONF_DIR/shell.dconf"

echo "  Exporting extension lists..."
gsettings get org.gnome.shell enabled-extensions 2>/dev/null \
  | python3 -c "import sys,json; xs=json.loads(sys.stdin.read().replace(\"'\",'\"')); print('\n'.join(xs))" \
  > "$EXT_DIR/enabled.txt" 2>/dev/null || \
  gsettings get org.gnome.shell enabled-extensions | tr -d "[]'" | tr ',' '\n' | sed 's/^ *//' \
  > "$EXT_DIR/enabled.txt"

gsettings get org.gnome.shell disabled-extensions 2>/dev/null \
  | python3 -c "import sys,json; xs=json.loads(sys.stdin.read().replace(\"'\",'\"')); print('\n'.join(xs))" \
  > "$EXT_DIR/disabled.txt" 2>/dev/null || \
  gsettings get org.gnome.shell disabled-extensions | tr -d "[]'" | tr ',' '\n' | sed 's/^ *//' \
  > "$EXT_DIR/disabled.txt"

echo "  Exporting per-extension dconf settings..."
EXT_NAMES=$(dconf list /org/gnome/shell/extensions/ 2>/dev/null || true)
for ext in $EXT_NAMES; do
  clean_name=$(echo "$ext" | tr -d '/')
  dconf dump "/org/gnome/shell/extensions/$ext" > "$EXT_DIR/settings-$clean_name.dconf" 2>/dev/null || true
done

echo "  Exporting wallpaper..."
WALL_URI=$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null || echo "")
WALL_PATH=$(echo "$WALL_URI" | sed "s|^'file://||; s|'$||")
if [ -n "$WALL_PATH" ] && [ -f "$WALL_PATH" ]; then
  cp "$WALL_PATH" "$WALLPAPER_DIR/current-wallpaper.jpg" 2>/dev/null || \
    cp "$WALL_PATH" "$WALLPAPER_DIR/current-wallpaper" 2>/dev/null || true
  echo "  Wallpaper: $WALL_PATH"
else
  echo "  Wallpaper: (none found)"
fi

WALL_DARK=$(gsettings get org.gnome.desktop.background picture-uri-dark 2>/dev/null || echo "")
WALL_DARK_PATH=$(echo "$WALL_DARK" | sed "s|^'file://||; s|'$||")
if [ -n "$WALL_DARK_PATH" ] && [ -f "$WALL_DARK_PATH" ] && [ "$WALL_DARK_PATH" != "$WALL_PATH" ]; then
  cp "$WALL_DARK_PATH" "$WALLPAPER_DIR/current-wallpaper-dark.jpg" 2>/dev/null || \
    cp "$WALL_DARK_PATH" "$WALLPAPER_DIR/current-wallpaper-dark" 2>/dev/null || true
  echo "  Dark wallpaper: $WALL_DARK_PATH"
fi

echo ""
echo "  Exported to: $BACKUP_DIR"
echo "  Files:"
find "$BACKUP_DIR" -type f | sed 's/^/    /'

echo ""
echo "=== Export complete ==="
