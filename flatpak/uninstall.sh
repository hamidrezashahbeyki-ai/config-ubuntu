#!/usr/bin/env bash
set -euo pipefail

# Confirm before proceeding
read -rp "This will delete ALL Flatpak apps and the Flatpak package. Continue? (y/N) " yn
[[ $yn =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# 1. Remove all apps
flatpak uninstall --all --user 2>/dev/null || true
sudo flatpak uninstall --all --system 2>/dev/null || true

# 2. Uninstall Flatpak itself (Ubuntu uses apt)
sudo apt remove --purge -y flatpak

# 3. Delete all leftover data
rm -rf ~/.local/share/flatpak ~/.cache/flatpak ~/.config/flatpak
sudo rm -rf /var/lib/flatpak /var/cache/flatpak /etc/flatpak

echo "✅ Flatpak fully removed and space freed."
