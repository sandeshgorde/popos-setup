# PopOS Setup

My personal Pop!_OS development environment backup.

## Includes

- GNOME settings (dconf, extensions, wallpapers, keybindings, dock, workspaces)
- Keyd keyboard layout
- Sublime Text config
- Shell setup
- Package installer

---

## Setup (Fresh Install)

```bash
git clone https://github.com/sandeshgorde/popos-setup.git
cd popos-setup
bash scripts/install.sh
bash scripts/setup.sh
```

---

## Update Snapshot (Run on current system)

```bash
bash popos/gnome/export.sh

---

## Restore Existing System

```bash
bash scripts/install.sh
bash scripts/setup.sh
```
