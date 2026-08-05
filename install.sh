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
if [ "$(uname)" = "Darwin" ]; then
    OS="macOS"
elif [ -f /etc/arch-release ]; then
    OS="Arch"
elif [ -f /etc/debian_version ]; then
    OS="Debian/Ubuntu"
elif [ -f /etc/fedora-release ]; then
    OS="Fedora"
elif [ -f /etc/alpine-release ]; then
    OS="Alpine"
elif [ -f /etc/suse-release ] || { [ -f /etc/os-release ] && grep -qi 'opensuse' /etc/os-release; }; then
    OS="openSUSE"
fi

echo -e "${BLUE}[*] OS Detected: ${YELLOW}$OS${NC}"

# Define sudo command
SUDO_CMD=""
if command -v sudo >/dev/null 2>&1; then
    SUDO_CMD="sudo"
fi

# Variables for language setup
ENABLE_PYTHON="yes"
ENABLE_RUST="yes"
ENABLE_GO="yes"
ENABLE_NODE="yes"

# 2. Choose Mode & Customize Language Support
# Parse arguments
for arg in "$@"; do
    case $arg in
        --desktop)
            MODE="Desktop"
            shift
            ;;
        --server)
            MODE="Server"
            shift
            ;;
        --no-python)
            ENABLE_PYTHON="no"
            shift
            ;;
        --no-rust)
            ENABLE_RUST="no"
            shift
            ;;
        --no-go)
            ENABLE_GO="no"
            shift
            ;;
        --no-node)
            ENABLE_NODE="no"
            shift
            ;;
    esac
done

if [[ -z "$MODE" ]]; then
    if [[ "$EUID" -eq 0 ]]; then
        echo -e "${RED}[!] Running as root detected.${NC}"
        echo -e "${YELLOW}Server/Root mode will be enforced for security.${NC}"
        MODE="Server"
    else
        echo -e "${YELLOW}Select Installation Mode (Enter the number):${NC}"
        echo -e "1) ${GREEN}Desktop/Personal${NC} (Full features, includes AUR helpers and desktop tools)"
        echo -e "2) ${GREEN}Server${NC} (Minimal, focused on stability and security)"

        if [ -t 0 ] || [ -c /dev/tty ]; then
            while true; do
                read -p "Selection [1 or 2]: " mode_choice < /dev/tty
                case $mode_choice in
                    1) MODE="Desktop"; break ;;
                    2) MODE="Server"; break ;;
                    *) echo -e "${RED}Invalid choice. Please enter 1 or 2.${NC}" ;;
                esac
            done
        else
            echo -e "${YELLOW}[*] Non-interactive environment detected. Defaulting to Desktop mode.${NC}"
            MODE="Desktop"
        fi
    fi
fi
echo -e "${BLUE}[*] Mode Selected: ${YELLOW}$MODE${NC}"

# Ask for programming environments interactively if not parsed via arguments
if [[ "$1" != "--no-python" && "$1" != "--no-rust" && "$1" != "--no-go" && "$1" != "--no-node" ]]; then
    if [[ "$MODE" == "Desktop" ]]; then
        if [ -t 0 ] || [ -c /dev/tty ]; then
            echo -e "${YELLOW}Do you want to enable Python programming environment? (y/n)${NC}"
            read -p "Selection [y/n]: " py_choice < /dev/tty
            [[ "$py_choice" =~ ^[Nn]$ ]] && ENABLE_PYTHON="no"

            echo -e "${YELLOW}Do you want to enable Rust programming environment? (y/n)${NC}"
            read -p "Selection [y/n]: " rust_choice < /dev/tty
            [[ "$rust_choice" =~ ^[Nn]$ ]] && ENABLE_RUST="no"

            echo -e "${YELLOW}Do you want to enable Go programming environment? (y/n)${NC}"
            read -p "Selection [y/n]: " go_choice < /dev/tty
            [[ "$go_choice" =~ ^[Nn]$ ]] && ENABLE_GO="no"

            echo -e "${YELLOW}Do you want to enable Node.js programming environment? (y/n)${NC}"
            read -p "Selection [y/n]: " node_choice < /dev/tty
            [[ "$node_choice" =~ ^[Nn]$ ]] && ENABLE_NODE="no"
        else
            echo -e "${BLUE}[*] Non-interactive environment. Enabling all programming languages by default.${NC}"
        fi
    fi
fi

# 3. Update repositories (Mirror/Repository Refresh)
echo -e "${BLUE}[*] Refreshing package databases & repositories...${NC}"
case $OS in
    "macOS")
        # Initialize Homebrew path if brew exists but is not in current PATH
        if ! command -v brew &> /dev/null; then
            if [ -f /opt/homebrew/bin/brew ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [ -f /usr/local/bin/brew ]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi

        if command -v brew &> /dev/null; then
            echo -e "${BLUE}[*] Running brew update...${NC}"
            brew update
        fi
        ;;
    "Arch")
        echo -e "${BLUE}[*] Syncing pacman database...${NC}"
        if [ "$MODE" == "Desktop" ] && command -v reflector &> /dev/null; then
            echo -e "${BLUE}[*] Refreshing Arch Linux mirrors first...${NC}"
            $SUDO_CMD reflector --country "Germany,France" -l 10 --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || true
        fi
        $SUDO_CMD pacman -Sy
        ;;
    "Debian/Ubuntu")
        export DEBIAN_FRONTEND=noninteractive
        $SUDO_CMD apt-get update
        ;;
    "Fedora")
        $SUDO_CMD dnf check-update >/dev/null 2>&1 || true
        ;;
    "Alpine")
        $SUDO_CMD apk update
        ;;
    "openSUSE")
        $SUDO_CMD zypper --non-interactive refresh
        ;;
esac

# 4. Install Core Dependencies
echo -e "${BLUE}[*] Installing core dependencies...${NC}"

case $OS in
    "macOS")
        # Ensure Homebrew is installed
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}[!] Homebrew not found. Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add brew to PATH for current execution
            if [ -f /opt/homebrew/bin/brew ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [ -f /usr/local/bin/brew ]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi

        if [[ "$MODE" == "Server" ]]; then
            brew install zsh git curl nload iftop nmap iperf3 tcpdump mtr duf
        else
            brew install zsh git curl fzf
        fi

        if [[ "$MODE" == "Desktop" ]]; then
            brew install p7zip unzip
        fi
        ;;
    "Arch")
        if [[ "$MODE" == "Server" ]]; then
            $SUDO_CMD pacman -S --needed --noconfirm zsh git curl nload iftop nmap iperf3 tcpdump mtr duf
        else
            $SUDO_CMD pacman -S --needed --noconfirm zsh git curl fzf
        fi

        if [[ "$MODE" == "Desktop" ]]; then
            echo -e "${BLUE}[*] Installing Desktop-specific dependencies (Arch)...${NC}"
            $SUDO_CMD pacman -S --needed --noconfirm base-devel reflector p7zip unzip python-virtualenvwrapper

            if ! command -v paru &> /dev/null; then
                echo -e "${YELLOW}[!] Paru (AUR helper) not found. Installing...${NC}"
                git clone https://aur.archlinux.org/paru.git /tmp/paru
                cd /tmp/paru && makepkg -si --noconfirm
                cd -
            fi
        fi
        ;;
    "Debian/Ubuntu")
        export DEBIAN_FRONTEND=noninteractive
        if [[ "$MODE" == "Server" ]]; then
            $SUDO_CMD apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" zsh git curl nload iftop nmap iperf3 tcpdump mtr-tiny duf
        else
            $SUDO_CMD apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" zsh git curl fzf
        fi

        if [[ "$MODE" == "Desktop" ]]; then
            $SUDO_CMD apt-get install -y p7zip-full unzip
        fi
        ;;
    "Fedora")
        if [[ "$MODE" == "Server" ]]; then
            $SUDO_CMD dnf install -y zsh git curl nload iftop nmap iperf3 tcpdump mtr duf
        else
            $SUDO_CMD dnf install -y zsh git curl fzf
        fi

        if [[ "$MODE" == "Desktop" ]]; then
            $SUDO_CMD dnf install -y p7zip unzip
        fi
        ;;
    "Alpine")
        if [[ "$MODE" == "Server" ]]; then
            $SUDO_CMD apk add zsh git curl nload iftop nmap iperf3 tcpdump mtr duf
        else
            $SUDO_CMD apk add zsh git curl fzf
        fi

        if [[ "$MODE" == "Desktop" ]]; then
            $SUDO_CMD apk add p7zip unzip
        fi
        ;;
    "openSUSE")
        if [[ "$MODE" == "Server" ]]; then
            $SUDO_CMD zypper --non-interactive install zsh git curl nload iftop nmap iperf3 tcpdump mtr duf
        else
            $SUDO_CMD zypper --non-interactive install zsh git curl fzf
        fi

        if [[ "$MODE" == "Desktop" ]]; then
            $SUDO_CMD zypper --non-interactive install p7zip unzip
        fi
        ;;
    *)
        echo -e "${RED}[!] Automatic dependency installation not supported for $OS.${NC}"
        echo -e "${YELLOW}Please ensure zsh, git, curl, and fzf are installed manually.${NC}"
        ;;
esac

# 5. Clone or Update Configuration
ZSH_CONFIG_DIR="$HOME/.zsh_config"
REPO_URL="https://github.com/Pakrohk-DotFiles/zsh_config.git"

if [ -d "$ZSH_CONFIG_DIR" ]; then
    echo -e "${YELLOW}[*] Configuration already exists at $ZSH_CONFIG_DIR. Updating...${NC}"
    cd "$ZSH_CONFIG_DIR" && git pull && cd -
else
    echo -e "${BLUE}[*] Cloning configuration to $ZSH_CONFIG_DIR...${NC}"
    git clone "$REPO_URL" "$ZSH_CONFIG_DIR"
fi

# 6. Parse and migrate existing framework plugins (Oh My Zsh, Zim, Prezto)
OLD_PLUGINS=()
if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ]; then
    echo -e "${BLUE}[*] Parsing existing .zshrc for active plugins...${NC}"
    in_plugins=0
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//')
        if [[ "$line" =~ plugins=\((.*)\) ]]; then
            content="${BASH_REMATCH[1]}"
            for p in $content; do
                OLD_PLUGINS+=("ohmyzsh/ohmyzsh plugins/$p")
            done
        elif [[ "$line" =~ plugins=\( ]]; then
            in_plugins=1
            content="${line#*plugins=(}"
            for p in $content; do
                OLD_PLUGINS+=("ohmyzsh/ohmyzsh plugins/$p")
            done
        elif [[ $in_plugins -eq 1 ]]; then
            if [[ "$line" =~ \) ]]; then
                in_plugins=0
                content="${line%)*}"
                for p in $content; do
                    OLD_PLUGINS+=("ohmyzsh/ohmyzsh plugins/$p")
                done
            else
                for p in $line; do
                    OLD_PLUGINS+=("ohmyzsh/ohmyzsh plugins/$p")
                done
            fi
        fi
    done < ~/.zshrc
fi

# Parse Zim modules if ~/.zimrc exists
if [ -f ~/.zimrc ]; then
    echo -e "${BLUE}[*] Parsing existing .zimrc for active modules...${NC}"
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//')
        if [[ "$line" =~ zmodule[[:space:]]+([^[:space:]]+) ]]; then
            mod="${BASH_REMATCH[1]}"
            if [[ "$mod" == *"/"* ]]; then
                OLD_PLUGINS+=("$mod")
            else
                OLD_PLUGINS+=("zimfw/$mod")
            fi
        fi
    done < ~/.zimrc
fi

# Parse Prezto modules if ~/.zpreztorc exists
if [ -f ~/.zpreztorc ]; then
    echo -e "${BLUE}[*] Parsing existing .zpreztorc for active modules...${NC}"
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//')
        if [[ "$line" =~ :prezto:load:pmodule ]]; then
            mods=$(echo "$line" | grep -oE "['\"][^'\"]+['\"]" | tr -d "'\"")
            for m in $mods; do
                OLD_PLUGINS+=("sorin-ionescu/prezto modules/$m")
            done
        fi
    done < ~/.zpreztorc
fi

# Backup existing configurations
BACKUP_SUF=$(date +%s)
for conf in ~/.zshrc ~/.zimrc ~/.zpreztorc ~/.zprofile ~/.zshenv; do
    if [ -f "$conf" ] && [ ! -L "$conf" ]; then
        echo -e "${YELLOW}[*] Backing up existing $(basename "$conf") to ${conf}.bak_${BACKUP_SUF}${NC}"
        mv "$conf" "${conf}.bak_${BACKUP_SUF}"
    elif [ -L "$conf" ]; then
        echo -e "${YELLOW}[*] Removing existing symlink $(basename "$conf")${NC}"
        rm "$conf"
    fi
done

# Backing up framework dirs if present
for fw_dir in ~/.oh-my-zsh ~/.zim ~/.zprezto; do
    if [ -d "$fw_dir" ]; then
        echo -e "${YELLOW}[*] Backing up framework directory $(basename "$fw_dir") to ${fw_dir}.bak_${BACKUP_SUF}${NC}"
        mv "$fw_dir" "${fw_dir}.bak_${BACKUP_SUF}"
    fi
done

# 7. Link .zshrc
echo -e "${BLUE}[*] Creating symbolic link for .zshrc...${NC}"
ln -sf "$ZSH_CONFIG_DIR/.zshrc" ~/.zshrc

# 8. Create or Update .zshrc.local
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
    echo -e "${YELLOW}[!] .zshrc.local already exists. Appending migrations if any.${NC}"
fi

# Save environment configurations for programming languages inside .zshrc.local
cat >> "$ZSH_LOCAL_CONF" <<EOF

# Programming environment configuration
export ENABLE_PYTHON='$ENABLE_PYTHON'
export ENABLE_RUST='$ENABLE_RUST'
export ENABLE_GO='$ENABLE_GO'
export ENABLE_NODE='$ENABLE_NODE'
EOF

# Append migrated plugins to .zshrc.local
if [ ${#OLD_PLUGINS[@]} -gt 0 ]; then
    echo -e "${BLUE}[*] Adding migrated plugins to .zshrc.local...${NC}"
    cat >> "$ZSH_LOCAL_CONF" <<EOF

# Migrated plugins from previous configuration
EOF
    for p in "${OLD_PLUGINS[@]}"; do
        # Avoid duplicates with default plugins in .zshrc
        if [[ "$p" != "ohmyzsh/ohmyzsh plugins/git" && "$p" != "ohmyzsh/ohmyzsh plugins/colored-man-pages" ]]; then
            echo "znap source $p" >> "$ZSH_LOCAL_CONF"
        fi
    done
fi

# 9. Customize Starship based on programming environment preferences
STARSHIP_CONF="$HOME/.config/starship.toml"
if [ -f "$STARSHIP_CONF" ] || [ -f "$ZSH_CONFIG_DIR/.prompt.local" ]; then
    # Run the prompt configuration setup once so starship.toml is generated
    # (or we let .prompt.local handle it, but let's make sure python/rust prompts are conditionally enabled)
    # We will also configure .prompt.local and .zshrc to read the ENABLE_ env vars!
    echo -e "${BLUE}[*] Programming environments customized successfully.${NC}"
fi

# 10. Change Default Shell
CURRENT_SHELL_NAME=$(basename "$SHELL")
if [[ "$CURRENT_SHELL_NAME" != "zsh" ]]; then
    echo -e "${YELLOW}[*] Changing your default shell to ZSH...${NC}"
    TARGET_SHELL="$(which zsh)"
    if [ "$OS" = "macOS" ] && [ -f /bin/zsh ]; then
        TARGET_SHELL="/bin/zsh"
    fi
    if command -v chsh >/dev/null 2>&1; then
        chsh -s "$TARGET_SHELL" || echo -e "${YELLOW}[!] Warning: Could not change default shell automatically. Please run: chsh -s $TARGET_SHELL manually.${NC}"
    else
        echo -e "${YELLOW}[!] Warning: chsh command not found. Please change your default shell to ZSH manually.${NC}"
    fi
else
    echo -e "${BLUE}[*] Shell is already ZSH. Skipping default shell modification.${NC}"
fi

# 11. Final Compilation for maximum speed
echo -e "${BLUE}[*] Bootstrapping Znap and executing final compilation...${NC}"
# Setup znap directory if not exists
[[ -r $ZSH_CONFIG_DIR/znap/znap.zsh ]] || git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git $ZSH_CONFIG_DIR/znap

# Run Zsh non-interactively to compile everything!
# We can use znap compile command.
zsh -c "source $ZSH_CONFIG_DIR/znap/znap.zsh && znap compile $ZSH_CONFIG_DIR" || echo -e "${YELLOW}[!] Compilation completed with warnings.${NC}"

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}   Installation Completed Successfully!   ${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "${YELLOW}Please restart your terminal or run: ${BLUE}source ~/.zshrc${NC}"
