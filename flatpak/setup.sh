#!/usr/bin/env bash
set -e 

RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
RESET='\e[0m'

echo -e "${GREEN}Setting up Flathub on Ubuntu${RESET}"

if ! command -v flatpak &> /dev/null; then
    echo "Flatpak not found. Installing..."
    sudo apt install -y flatpak
else
    echo "Flatpak is already installed."
fi

echo "Installing GNOME Software plugin for Flatpak..."
sudo apt install -y gnome-software-plugin-flatpak

echo "Adding Flathub repository..."
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo

