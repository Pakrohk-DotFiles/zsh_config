#!/bin/bash

# --- Enhanced ZSH Configuration Installer ---
# This script installs ZSH and configures it with Pakrohk-DotFiles/zsh-config.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}   Enhanced ZSH Configuration Installer   ${NC}"
echo -e "${BLUE}==========================================${NC}"

# 1. Detect OS
OS="Unknown"
if [ -f /etc/arch-release ]; then
    OS="Arch"
elif [ -f /etc/debian_version ]; then
    OS="Debian/Ubuntu"
elif [ -f /etc/fedora-release ]; then
    OS="Fedora"
fi

echo -e "${BLUE}[*] OS Detected: ${YELLOW}$OS${NC}"

# 2. Choose Mode
echo -e "${YELLOW}Select Installation Mode:${NC}"
echo -e "1) ${GREEN}Desktop/Personal${NC} (Full features, includes AUR helpers and desktop tools)"
echo -e "2) ${GREEN}Server${NC} (Minimal, focused on stability and security)"
read -p "Enter choice [1-2]: " mode_choice

if [[ "$mode_choice" == "1" ]]; then
    MODE="Desktop"
else
    MODE="Server"
fi
echo -e "${BLUE}[*] Mode Selected: ${YELLOW}$MODE${NC}"

# 3. Install Core Dependencies
echo -e "${BLUE}[*] Installing core dependencies...${NC}"

case $OS in
    "Arch")
        sudo pacman -Sy --needed --noconfirm zsh git curl fzf
        if [[ "$MODE" == "Desktop" ]]; then
            echo -e "${BLUE}[*] Installing Desktop-specific dependencies (Arch)...${NC}"
            sudo pacman -S --needed --noconfirm base-devel reflector p7zip unzip z python-virtualenvwrapper

            if ! command -v paru &> /dev/null; then
                echo -e "${YELLOW}[!] Paru (AUR helper) not found. Installing...${NC}"
                git clone https://aur.archlinux.org/paru.git /tmp/paru
                cd /tmp/paru && makepkg -si --noconfirm
                cd -
            fi
        fi
        ;;
    "Debian/Ubuntu")
        sudo apt-get update
        sudo apt-get install -y zsh git curl fzf
        if [[ "$MODE" == "Desktop" ]]; then
            sudo apt-get install -y p7zip-full unzip
        fi
        ;;
    "Fedora")
        sudo dnf install -y zsh git curl fzf
        if [[ "$MODE" == "Desktop" ]]; then
            sudo dnf install -y p7zip unzip
        fi
        ;;
    *)
        echo -e "${RED}[!] Automatic dependency installation not supported for $OS.${NC}"
        echo -e "${YELLOW}Please ensure zsh, git, curl, and fzf are installed manually.${NC}"
        ;;
esac

# 4. Clone or Update Configuration
ZSH_CONFIG_DIR="$HOME/.zsh_config"
REPO_URL="https://github.com/Pakrohk-DotFiles/zsh-config.git"

if [ -d "$ZSH_CONFIG_DIR" ]; then
    echo -e "${YELLOW}[*] Configuration already exists at $ZSH_CONFIG_DIR. Updating...${NC}"
    cd "$ZSH_CONFIG_DIR" && git pull && cd -
else
    echo -e "${BLUE}[*] Cloning configuration to $ZSH_CONFIG_DIR...${NC}"
    git clone "$REPO_URL" "$ZSH_CONFIG_DIR"
fi

# 5. Backup and Link .zshrc
if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ]; then
    echo -e "${YELLOW}[*] Backing up existing .zshrc to ~/.zshrc.bak${NC}"
    mv ~/.zshrc ~/.zshrc.bak
fi

echo -e "${BLUE}[*] Creating symbolic link for .zshrc...${NC}"
ln -sf "$ZSH_CONFIG_DIR/.zshrc" ~/.zshrc

# 6. Create or Update .zshrc.local
ZSH_LOCAL_CONF="$ZSH_CONFIG_DIR/.zshrc.local"
if [ ! -f "$ZSH_LOCAL_CONF" ]; then
    echo -e "${BLUE}[*] Creating .zshrc.local with $MODE defaults...${NC}"
    if [[ "$MODE" == "Server" ]]; then
        cat > "$ZSH_LOCAL_CONF" <<EOF
# Machine-specific settings for Server
export EDITOR='vim'
export BROWSER='echo'
export TERMINAL='xterm'

# Server-specific behavior
export ZSH_ENV_TYPE='server'
EOF
    else
        cat > "$ZSH_LOCAL_CONF" <<EOF
# Machine-specific settings for Desktop
export EDITOR='nvim'
export BROWSER='firefox'
export TERMINAL='kitty'

export ZSH_ENV_TYPE='desktop'
EOF
    fi
else
    echo -e "${YELLOW}[!] .zshrc.local already exists. Skipping default creation.${NC}"
fi

# 7. Change Default Shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo -e "${YELLOW}[*] Changing your default shell to ZSH...${NC}"
    chsh -s "$(which zsh)"
fi

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}   Installation Completed Successfully!   ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "${YELLOW}Please restart your terminal or run: ${BLUE}source ~/.zshrc${NC}"
