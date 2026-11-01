#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup existing config if it exists and is not a symlink
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to ${target}.backup"
        mv "$target" "${target}.backup"
    elif [ -L "$target" ]; then
        echo "Removing existing symlink $target"
        rm "$target"
    fi
}

# Create symlink
create_link() {
    local source="$1"
    local target="$2"
    backup_if_exists "$target"
    ln -s "$source" "$target"
    echo "Linked $source -> $target"
}

echo "Installing dotfiles..."

# Ensure .config directory exists
mkdir -p "$HOME/.config"

# Neovim
create_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo "Done!"
