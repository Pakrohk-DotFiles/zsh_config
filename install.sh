#!/usr/bin/env bash
# Enhanced ZSH Configuration Installer - Smart, idempotent, user-friendly
# Detects OS, existing config, offers choices, produces optimal setup

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Colors & UI helpers
# ──────────────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log()      { echo -e "${BLUE}[*]${NC} $*"; }
success()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn()     { echo -e "${YELLOW}[!]${NC} $*"; }
error()    { echo -e "${RED}[✗]${NC} $*"; }
info()     { echo -e "${CYAN}[i]${NC} $*"; }
prompt()   { echo -ne "${BOLD}$*${NC} "; }
section()  { echo -e "\n${BLUE}────────────────── $* ──────────────────${NC}\n"; }

# ──────────────────────────────────────────────────────────────────────────────
# Detect OS
# ──────────────────────────────────────────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Darwin)        OS="macOS" ;;
        Linux)
            if [[ -f /etc/arch-release ]]; then OS="Arch"
            elif [[ -f /etc/debian_version ]]; then OS="Debian/Ubuntu"
            elif [[ -f /etc/fedora-release ]]; then OS="Fedora"
            elif [[ -f /etc/alpine-release ]]; then OS="Alpine"
            elif [[ -f /etc/os-release ]]; then
                . /etc/os-release
                case "$ID" in
                    opensuse*) OS="openSUSE" ;;
                    *) OS="Linux" ;;
                esac
            else OS="Linux"; fi
            ;;
        *MSYS*|*MINGW*|*CYGWIN*) OS="Windows-MSYS" ;;
        *) OS="Unknown" ;;
    esac
    log "OS detected: $OS"
}

# ──────────────────────────────────────────────────────────────────────────────
# Detect package manager & install command
# ──────────────────────────────────────────────────────────────────────────────
get_pkg_manager() {
    case "$OS" in
        macOS)        PKG_MGR="brew"; PKG_INSTALL="brew install" ;;
        Arch)         PKG_MGR="pacman"; PKG_INSTALL="pacman -S --needed --noconfirm" ;;
        "Debian/Ubuntu") PKG_MGR="apt";  PKG_INSTALL="apt-get install -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold" ;;
        Fedora)       PKG_MGR="dnf";    PKG_INSTALL="dnf install -y" ;;
        Alpine)       PKG_MGR="apk";    PKG_INSTALL="apk add" ;;
        openSUSE)     PKG_MGR="zypper"; PKG_INSTALL="zypper --non-interactive install" ;;
        Windows-MSYS) PKG_MGR="pacman"; PKG_INSTALL="pacman -S --needed --noconfirm" ;;
        *)            PKG_MGR="";       PKG_INSTALL="" ;;
    esac
}

# ──────────────────────────────────────────────────────────────────────────────
# Detect existing zsh config & frameworks
# ──────────────────────────────────────────────────────────────────────────────
detect_existing_config() {
    EXISTING_ZSHRC=0
    EXISTING_FRAMEWORKS=()
    
    [[ -f ~/.zshrc && ! -L ~/.zshrc ]] && EXISTING_ZSHRC=1
    
    for fw in oh-my-zsh zim zprezto; do
        [[ -d ~/.$fw ]] && EXISTING_FRAMEWORKS+=("$fw")
    done
    
    if [[ $EXISTING_ZSHRC -eq 1 || ${#EXISTING_FRAMEWORKS[@]} -gt 0 ]]; then
        warn "Existing zsh configuration detected"
        [[ $EXISTING_ZSHRC -eq 1 ]] && info "  - ~/.zshrc (regular file)"
        for fw in "${EXISTING_FRAMEWORKS[@]}"; do info "  - ~/$fw"; done
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Smart defaults based on environment
# ──────────────────────────────────────────────────────────────────────────────
set_smart_defaults() {
    # Default: Desktop mode for regular users, Server for root
    if [[ $EUID -eq 0 ]]; then
        DEFAULT_MODE="Server"
    else
        DEFAULT_MODE="Desktop"
    fi
    
    # Detect if we're in a container/ci
    if [[ -f /.dockerenv ]] || [[ -n "${CI:-}" ]] || [[ ! -t 0 ]]; then
        NON_INTERACTIVE=1
    else
        NON_INTERACTIVE=0
    fi
    
    # Language defaults - enable all unless explicitly disabled
    ENABLE_PYTHON="${ENABLE_PYTHON:-yes}"
    ENABLE_RUST="${ENABLE_RUST:-yes}"
    ENABLE_GO="${ENABLE_GO:-yes}"
    ENABLE_NODE="${ENABLE_NODE:-yes}"
}

# ──────────────────────────────────────────────────────────────────────────────
# Parse CLI arguments
# ──────────────────────────────────────────────────────────────────────────────
parse_args() {
    MODE=""
    SKIP_DEPS=0
    SKIP_SHELL=0
    FORCE=0
    DRY_RUN=0
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --desktop)        MODE="Desktop"; shift ;;
            --server)         MODE="Server"; shift ;;
            --skip-deps)      SKIP_DEPS=1; shift ;;
            --skip-shell)     SKIP_SHELL=1; shift ;;
            --force)          FORCE=1; shift ;;
            --dry-run)        DRY_RUN=1; shift ;;
            --non-interactive) NON_INTERACTIVE=1; shift ;;
            --no-python)      ENABLE_PYTHON="no"; shift ;;
            --no-rust)        ENABLE_RUST="no"; shift ;;
            --no-go)          ENABLE_GO="no"; shift ;;
            --no-node)        ENABLE_NODE="no"; shift ;;
            -h|--help)
                cat <<EOF
Usage: $0 [options]

Options:
  --desktop           Force Desktop mode (full features)
  --server            Force Server mode (minimal)
  --skip-deps         Skip dependency installation
  --skip-shell        Don't change default shell
  --force             Overwrite existing config without prompting
  --dry-run           Show what would be done without doing it
  --non-interactive   Run without prompts (use defaults/env vars)
  --no-python/--no-rust/--no-go/--no-node  Disable language environments
  -h, --help          Show this help

Environment variables:
  ENABLE_PYTHON=yes|no  (default: yes)
  ENABLE_RUST=yes|no    (default: yes)
  ENABLE_GO=yes|no      (default: yes)
  ENABLE_NODE=yes|no    (default: yes)
EOF
                exit 0
                ;;
            *) error "Unknown option: $1"; exit 1 ;;
        esac
    done
    
    # Use default mode if not set
    MODE="${MODE:-$DEFAULT_MODE}"
    log "Mode: $MODE | Non-interactive: $NON_INTERACTIVE"
}

# ──────────────────────────────────────────────────────────────────────────────
# Install dependencies based on OS and mode
# ──────────────────────────────────────────────────────────────────────────────
install_deps() {
    [[ $SKIP_DEPS -eq 1 ]] && { info "Skipping dependency installation"; return; }
    [[ -z "$PKG_INSTALL" ]] && { warn "No package manager for $OS; skipping"; return; }
    
    section "Installing dependencies"
    
    local base_pkgs=()
    local extra_pkgs=()
    
    case "$OS" in
        macOS)
            base_pkgs=(zsh git curl fzf)
            extra_pkgs=(p7zip unzip)
            if ! command -v brew &>/dev/null; then
                log "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
            fi
            ;;
        Arch)
            base_pkgs=(zsh git curl fzf)
            extra_pkgs=(base-devel reflector p7zip unzip)
            # Paru for AUR
            if [[ "$MODE" == "Desktop" ]] && ! command -v paru &>/dev/null; then
                log "Installing paru (AUR helper)..."
                git clone https://aur.archlinux.org/paru.git /tmp/paru && \
                (cd /tmp/paru && makepkg -si --noconfirm)
            fi
            ;;
        "Debian/Ubuntu")
            export DEBIAN_FRONTEND=noninteractive
            base_pkgs=(zsh git curl fzf)
            extra_pkgs=(p7zip-full unzip)
            ;;
        Fedora)
            base_pkgs=(zsh git curl fzf)
            extra_pkgs=(p7zip unzip)
            ;;
        Alpine)
            base_pkgs=(zsh git curl fzf)
            extra_pkgs=(p7zip unzip)
            ;;
        openSUSE)
            base_pkgs=(zsh git curl fzf)
            extra_pkgs=(p7zip unzip)
            ;;
        Windows-MSYS)
            base_pkgs=(zsh git curl fzf)
            extra_pkgs=(unzip p7zip)
            ;;
    esac
    
    # Server mode: add monitoring tools
    if [[ "$MODE" == "Server" ]]; then
        case "$OS" in
            Arch)        base_pkgs+=(nload iftop nmap iperf3 tcpdump mtr duf) ;;
            "Debian/Ubuntu") base_pkgs+=(nload iftop nmap iperf3 tcpdump mtr-tiny duf) ;;
            Fedora)      base_pkgs+=(nload iftop nmap iperf3 tcpdump mtr duf) ;;
            Alpine)      base_pkgs+=(nload iftop nmap iperf3 tcpdump mtr duf) ;;
            openSUSE)    base_pkgs+=(nload iftop nmap iperf3 tcpdump mtr duf) ;;
        esac
    fi
    
    if [[ $DRY_RUN -eq 1 ]]; then
        info "Would install: ${base_pkgs[*]} ${extra_pkgs[*]}"
        return
    fi
    
    log "Installing base packages..."
    $PKG_INSTALL "${base_pkgs[@]}"
    
    if [[ "$MODE" == "Desktop" && ${#extra_pkgs[@]} -gt 0 ]]; then
        log "Installing desktop extras..."
        $PKG_INSTALL "${extra_pkgs[@]}"
    fi
    
    success "Dependencies installed"
}

# ──────────────────────────────────────────────────────────────────────────────
# Clone or update config repo
# ──────────────────────────────────────────────────────────────────────────────
sync_config() {
    section "Syncing configuration"
    ZSH_CONFIG_DIR="$HOME/.zsh_config"
    REPO_URL="https://github.com/Pakrohk-DotFiles/zsh_config.git"
    
    if [[ -d "$ZSH_CONFIG_DIR" ]]; then
        log "Config exists, pulling latest..."
        [[ $DRY_RUN -eq 1 ]] && return
        git -C "$ZSH_CONFIG_DIR" pull --ff-only
    else
        log "Cloning config..."
        [[ $DRY_RUN -eq 1 ]] && return
        git clone "$REPO_URL" "$ZSH_CONFIG_DIR"
    fi
    
    # Ensure znap submodule
    [[ -r "$ZSH_CONFIG_DIR/znap/znap.zsh" ]] || {
        log "Bootstrapping znap..."
        [[ $DRY_RUN -eq 1 ]] && return
        git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git "$ZSH_CONFIG_DIR/znap"
    }
    success "Configuration synced"
}

# ──────────────────────────────────────────────────────────────────────────────
# Backup existing configs
# ──────────────────────────────────────────────────────────────────────────────
backup_existing() {
    section "Backing up existing configuration"
    local suffix=".bak.$(date +%s)"
    local backed_up=0
    
    for conf in ~/.zshrc ~/.zimrc ~/.zpreztorc ~/.zprofile ~/.zshenv; do
        if [[ -f "$conf" && ! -L "$conf" ]]; then
            log "Backing up $(basename "$conf")"
            [[ $DRY_RUN -eq 1 ]] || mv "$conf" "${conf}${suffix}"
            backed_up=1
        elif [[ -L "$conf" ]]; then
            log "Removing symlink $(basename "$conf")"
            [[ $DRY_RUN -eq 1 ]] || rm "$conf"
        fi
    done
    
    for fw_dir in ~/.oh-my-zsh ~/.zim ~/.zprezto; do
        if [[ -d "$fw_dir" ]]; then
            log "Backing up framework $fw_dir"
            [[ $DRY_RUN -eq 1 ]] || mv "$fw_dir" "${fw_dir}${suffix}"
            backed_up=1
        fi
    done
    
    [[ $backed_up -eq 1 ]] && success "Backup complete" || info "No existing config to backup"
}

# ──────────────────────────────────────────────────────────────────────────────
# Create symlink for .zshrc
# ──────────────────────────────────────────────────────────────────────────────
link_zshrc() {
    section "Linking .zshrc"
    [[ $DRY_RUN -eq 1 ]] && { info "Would symlink ~/.zshrc -> $ZSH_CONFIG_DIR/.zshrc"; return; }
    ln -sf "$ZSH_CONFIG_DIR/.zshrc" ~/.zshrc
    success ".zshrc linked"
}

# ──────────────────────────────────────────────────────────────────────────────
# Create/update .zshrc.local with smart defaults
# ──────────────────────────────────────────────────────────────────────────────
create_local_config() {
    section "Creating .zshrc.local"
    ZSH_LOCAL_CONF="$ZSH_CONFIG_DIR/.zshrc.local"
    
    if [[ -f "$ZSH_LOCAL_CONF" && $FORCE -eq 0 ]]; then
        info ".zshrc.local exists, preserving"
        return
    fi
    
    [[ $DRY_RUN -eq 1 ]] && { info "Would create .zshrc.local"; return; }
    
    cat > "$ZSH_LOCAL_CONF" <<EOF
# Machine-specific settings for $MODE
# Generated by install.sh on $(date)

EOF
    
    if [[ "$MODE" == "Server" ]]; then
        cat >> "$ZSH_LOCAL_CONF" <<'EOF'
export EDITOR='vim'
export BROWSER='echo'
export TERMINAL='xterm'
export ZSH_ENV_TYPE='server'
EOF
    else
        cat >> "$ZSH_LOCAL_CONF" <<'EOF'
export EDITOR='nvim'
export BROWSER='firefox'
export TERMINAL='kitty'
export ZSH_ENV_TYPE='desktop'
EOF
    fi
    
    cat >> "$ZSH_LOCAL_CONF" <<EOF

# Programming environment configuration
export ENABLE_PYTHON='$ENABLE_PYTHON'
export ENABLE_RUST='$ENABLE_RUST'
export ENABLE_GO='$ENABLE_GO'
export ENABLE_NODE='$ENABLE_NODE'
EOF
    
    success ".zshrc.local created"
}

# ──────────────────────────────────────────────────────────────────────────────
# Change default shell
# ──────────────────────────────────────────────────────────────────────────────
change_shell() {
    [[ $SKIP_SHELL -eq 1 ]] && { info "Skipping shell change"; return; }
    [[ $(basename "$SHELL") == "zsh" ]] && { success "Shell already zsh"; return; }
    
    section "Changing default shell to zsh"
    local zsh_path="$(command -v zsh)"
    [[ "$OS" == "macOS" && -f /bin/zsh ]] && zsh_path="/bin/zsh"
    
    [[ $DRY_RUN -eq 1 ]] && { info "Would run: chsh -s $zsh_path"; return; }
    
    if command -v chsh &>/dev/null; then
        chsh -s "$zsh_path" && success "Default shell changed to zsh" \
            || warn "Could not change shell automatically. Run: chsh -s $zsh_path"
    else
        warn "chsh not available. Change shell manually: chsh -s $zsh_path"
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Final compilation (idempotent, handles errors gracefully)
# ──────────────────────────────────────────────────────────────────────────────
final_compile() {
    section "Final compilation (speedup)"
    [[ $DRY_RUN -eq 1 ]] && { info "Would compile znap plugins"; return; }
    
    # Compile only what znap can handle; ignore failures gracefully
    zsh -c "
        source '$ZSH_CONFIG_DIR/znap/znap.zsh'
        znap compile '$ZSH_CONFIG_DIR' 2>&1 | grep -v 'file not found\\|can.t read file\\|parse error' || true
    " || true
    
    success "Compilation done (warnings ignored)"
}

# ──────────────────────────────────────────────────────────────────────────────
# Verify installation
# ──────────────────────────────────────────────────────────────────────────────
verify_install() {
    section "Verifying installation"
    
    if zsh -ic 'echo "ZSH_OK"' 2>&1 | grep -q "ZSH_OK"; then
        success "Zsh loads without errors"
    else
        error "Zsh startup has issues"
        return 1
    fi
    
    # Check key plugins
    local plugins=(fast-syntax-highlighting zsh-autosuggestions zsh-completions)
    for p in "${plugins[@]}"; do
        if [[ -d "$ZSH_CONFIG_DIR"/zsh-users/"$p" ]] || [[ -d "$ZSH_CONFIG_DIR"/zdharma-continuum/"$p" ]]; then
            info "  ✓ $p"
        fi
    done
    
    success "Verification complete"
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────
main() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${GREEN}   Enhanced ZSH Configuration Installer   ${NC}"
    echo -e "${BLUE}==========================================${NC}"
    
    detect_os
    get_pkg_manager
    detect_existing_config
    set_smart_defaults
    parse_args "$@"
    
    # Confirm in interactive mode unless forced
    if [[ $NON_INTERACTIVE -eq 0 && $FORCE -eq 0 && $DRY_RUN -eq 0 ]]; then
        echo
        prompt "Proceed with installation? [Y/n] "
        read -r confirm
        [[ "$confirm" =~ ^[Nn]$ ]] && { info "Cancelled"; exit 0; }
    fi
    
    install_deps
    sync_config
    backup_existing
    link_zshrc
    create_local_config
    change_shell
    final_compile
    verify_install
    
    echo -e "\n${GREEN}==========================================${NC}"
    echo -e "${GREEN}   Installation Completed Successfully!   ${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${YELLOW}Restart your terminal or run:${NC} ${BLUE}source ~/.zshrc${NC}"
}

main "$@"