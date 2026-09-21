#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"


echo "source $SCRIPT_DIR/aliases.sh" >> $HOME/.zshrc
