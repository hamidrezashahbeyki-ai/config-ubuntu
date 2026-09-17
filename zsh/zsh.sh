#!/usr/bin/env bash

set -euo pipefail

# ----- Config -----
INSTALL_PLUGINS=true      # set to false to skip extra plugins
CHANGE_DEFAULT_SHELL=true # set to false to keep your current login shell

# ----- Helpers -----
log()  { printf '\e[32m[+]\e[0m %s\n' "$*"; }
warn() { printf '\e[33m[!]\e[0m %s\n' "$*"; }
die()  { printf '\e[31m[x]\e[0m %s\n' "$*" >&2; exit 1; }

# ----- Preflight -----
command -v apt-get >/dev/null 2>&1 || die "apt-get not found — this script targets Ubuntu/Debian."

SUDO=""
if [[ ${EUID} -ne 0 ]]; then
  command -v sudo >/dev/null 2>&1 || die "Run as root, or install sudo first."
  SUDO="sudo"
else
  warn "Running as root — Zsh/OMZ will be installed for the root user."
fi

# ----- 1. Install packages -----
log "Updating package index..."
 $SUDO apt-get update -y

log "Installing zsh, git, curl..."
 $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y zsh git curl

ZSH_PATH="$(command -v zsh)"
log "Installed $(zsh --version) at $ZSH_PATH"

# ----- 2. Install Oh My Zsh (unattended) -----
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  warn "Oh My Zsh already present at ~/.oh-my-zsh — skipping."
else
  log "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Restore .zshrc from template if it's missing (e.g. leftover omz dir)
if [[ ! -f "$HOME/.zshrc" && -f "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" ]]; then
  cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
fi

# ----- 3. Install popular plugins -----
if [[ "$INSTALL_PLUGINS" == true && -d "$HOME/.oh-my-zsh" ]]; then
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  clone_if_missing() {
    local repo="$1" dest="$2"
    if [[ -d "$dest" ]]; then
      warn "$(basename "$dest") already installed — skipping."
    else
      log "Cloning $(basename "$dest")..."
      git clone --depth=1 "$repo" "$dest"
    fi
  }

  clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions"     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

  # Enable the plugins in ~/.zshrc
  if grep -q '^plugins=(git)' "$HOME/.zshrc"; then
    sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
    log "Plugins enabled in ~/.zshrc"
  else
    warn "Couldn't find 'plugins=(git)' in ~/.zshrc — add them manually:"
    warn "  plugins=(git zsh-autosuggestions zsh-syntax-highlighting)"
  fi
fi

# ----- 4. Set zsh as default shell -----
if [[ "$CHANGE_DEFAULT_SHELL" == true ]]; then
  if [[ "$SHELL" == "$ZSH_PATH" ]]; then
    log "zsh is already your default shell."
  else
    log "Setting zsh as default shell (may ask for your password)..."
    chsh -s "$ZSH_PATH" || warn "chsh failed - run manually: chsh -s $ZSH_PATH"
  fi
fi

log "All done! Open a new terminal, or run: exec $ZSH_PATH"
