#!/usr/bin/env zsh

# Cross-platform Package Management Helper using fzf
# Supports Arch Linux (pacman/paru), macOS (brew), Debian/Ubuntu (apt), Fedora (dnf), Alpine (apk), and openSUSE (zypper)

# Detect Package Manager
_detect_pkg_mgr() {
    if command -v paru >/dev/null 2>&1; then
        echo "paru"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v brew >/dev/null 2>&1; then
        echo "brew"
    elif command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v apk >/dev/null 2>&1; then
        echo "apk"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

PKG_MGR=$(_detect_pkg_mgr)

# Define sudo dynamically
SUDO_CMD=""
if command -v sudo >/dev/null 2>&1; then
    SUDO_CMD="sudo"
fi

show_help() {
    echo -e "\nPackage Management Help ($PKG_MGR):"
    echo "------------------------"
    echo "1. Search & Install (i)  : Search packages from repositories"
    echo "2. Remove Packages (r)   : Remove installed packages"
    echo "3. Clean Orphans (o)     : List and remove orphaned packages"
    echo "4. List Explicit (e)     : Show explicitly/manually installed packages"
    echo "5. List Foreign/Extra (f): Show AUR/Cask/Extra packages"
    echo -e "\nUsage Tips:"
    echo "- TAB to select multiple packages"
    echo "- Start typing to search"
    echo "- Ctrl+C to cancel"
    echo "------------------------"
}

confirm_action() {
    local prompt="$1"
    read -q "REPLY?$prompt [y/N]: " 
    echo
    [[ "$REPLY" =~ ^[Yy]$ ]]
}

search_and_install() {
    local packages
    case $PKG_MGR in
        "paru"|"pacman")
            packages=$(
                (pacman -Ss; paru -Ssa 2>/dev/null) | \
                grep -E "^[^ ]|^$" | \
                fzf --prompt="Search packages: " \
                    --multi \
                    --reverse \
                    --preview 'package=$(echo {} | cut -d" " -f1 | cut -d"/" -f2); if [ -n "$package" ]; then paru -Si "$package" 2>/dev/null || pacman -Si "$package" 2>/dev/null; fi' \
                    --bind "change:reload(pacman -Ss {q}; paru -Ssa {q} 2>/dev/null)" \
                    --header $'TAB to select multiple packages\nStart typing to search\nEnter to install' \
                    --disabled | \
                cut -d' ' -f1 | cut -d'/' -f2
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for installation: $packages"
                if confirm_action "Proceed with installation?"; then
                    if [ "$PKG_MGR" = "paru" ]; then
                        echo "$packages" | tr '\n' ' ' | xargs -r paru -S --noconfirm --needed
                    else
                        echo "$packages" | tr '\n' ' ' | xargs -r $SUDO_CMD pacman -S --noconfirm --needed
                    fi
                fi
            fi
            ;;
        "brew")
            # Fast, clean, one-per-line list of all installable formulae and casks
            packages=$(
                (brew formulae; brew casks) 2>/dev/null | \
                fzf --prompt="Search brew packages: " \
                    --multi \
                    --reverse \
                    --preview 'brew info {}' \
                    --header $'TAB to select multiple packages\nEnter to install'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for installation: $packages"
                if confirm_action "Proceed with installation?"; then
                    echo "$packages" | tr '\n' ' ' | xargs brew install
                fi
            fi
            ;;
        "apt")
            packages=$(
                apt-cache pkgnames | \
                fzf --prompt="Search apt packages: " \
                    --multi \
                    --reverse \
                    --preview 'apt-cache show {}' \
                    --header $'TAB to select multiple packages\nEnter to install'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for installation: $packages"
                if confirm_action "Proceed with installation?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD apt-get install -y
                fi
            fi
            ;;
        "dnf")
            packages=$(
                dnf list available | awk 'NR>1 {print $1}' | \
                fzf --prompt="Search dnf packages: " \
                    --multi \
                    --reverse \
                    --preview 'dnf info {}' \
                    --header $'TAB to select multiple packages\nEnter to install'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for installation: $packages"
                if confirm_action "Proceed with installation?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD dnf install -y
                fi
            fi
            ;;
        "apk")
            packages=$(
                apk search -q | \
                fzf --prompt="Search apk packages: " \
                    --multi \
                    --reverse \
                    --preview 'apk info {}' \
                    --header $'TAB to select multiple packages\nEnter to install'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for installation: $packages"
                if confirm_action "Proceed with installation?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD apk add
                fi
            fi
            ;;
        "zypper")
            packages=$(
                zypper se -t package | awk -F '|' 'NR>5 {print $2}' | tr -d ' ' | \
                fzf --prompt="Search zypper packages: " \
                    --multi \
                    --reverse \
                    --preview 'zypper info {}' \
                    --header $'TAB to select multiple packages\nEnter to install'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for installation: $packages"
                if confirm_action "Proceed with installation?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD zypper --non-interactive install
                fi
            fi
            ;;
        *)
            echo "Search and install not supported automatically for $PKG_MGR."
            ;;
    esac
}

remove_packages() {
    local packages
    case $PKG_MGR in
        "paru"|"pacman")
            packages=$(pacman -Qq | \
                fzf --prompt="Select packages to remove: " \
                    --multi \
                    --reverse \
                    --preview 'paru -Si {} 2>/dev/null || pacman -Si {}' \
                    --header $'TAB to select multiple packages\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs -r $SUDO_CMD pacman -Rs --noconfirm
                fi
            fi
            ;;
        "brew")
            packages=$( (brew list --formulae; brew list --casks) 2>/dev/null | \
                fzf --prompt="Select packages to remove: " \
                    --multi \
                    --reverse \
                    --preview 'brew info {}' \
                    --header $'TAB to select multiple packages\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs brew uninstall
                fi
            fi
            ;;
        "apt")
            packages=$(dpkg --get-selections | awk '{print $1}' | \
                fzf --prompt="Select packages to remove: " \
                    --multi \
                    --reverse \
                    --preview 'apt-cache show {}' \
                    --header $'TAB to select multiple packages\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD apt-get remove -y
                fi
            fi
            ;;
        "dnf")
            packages=$(dnf list installed | awk 'NR>1 {print $1}' | \
                fzf --prompt="Select packages to remove: " \
                    --multi \
                    --reverse \
                    --preview 'dnf info {}' \
                    --header $'TAB to select multiple packages\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD dnf remove -y
                fi
            fi
            ;;
        "apk")
            packages=$(apk info | \
                fzf --prompt="Select packages to remove: " \
                    --multi \
                    --reverse \
                    --preview 'apk info {}' \
                    --header $'TAB to select multiple packages\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD apk del
                fi
            fi
            ;;
        "zypper")
            packages=$(zypper se --installed-only -t package | awk -F '|' 'NR>5 {print $2}' | tr -d ' ' | \
                fzf --prompt="Select packages to remove: " \
                    --multi \
                    --reverse \
                    --preview 'zypper info {}' \
                    --header $'TAB to select multiple packages\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD zypper remove -y
                fi
            fi
            ;;
        *)
            echo "Remove packages not supported automatically for $PKG_MGR."
            ;;
    esac
}

clean_orphans() {
    local packages
    case $PKG_MGR in
        "paru"|"pacman")
            packages=$(pacman -Qdtq | \
                fzf --prompt="Orphaned packages: " \
                    --multi \
                    --reverse \
                    --preview 'paru -Si {} 2>/dev/null || pacman -Si {}' \
                    --header $'These packages are no longer required\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected orphaned packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs -r $SUDO_CMD pacman -Rs --noconfirm
                fi
            fi
            ;;
        "brew")
            packages=$(brew leaves | \
                fzf --prompt="Orphaned brew packages: " \
                    --multi \
                    --reverse \
                    --preview 'brew info {}' \
                    --header $'These are leaf packages (nothing depends on them)\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs brew uninstall
                fi
            fi
            ;;
        "apt")
            packages=$(apt-get -s autoremove | awk '/Remv/ {print $2}' | \
                fzf --prompt="Orphaned apt packages: " \
                    --multi \
                    --reverse \
                    --preview 'apt-cache show {}' \
                    --header $'These packages are no longer required\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected orphaned packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD apt-get remove -y
                fi
            fi
            ;;
        "dnf")
            packages=$(dnf repoquery --unneeded | \
                fzf --prompt="Orphaned dnf packages: " \
                    --multi \
                    --reverse \
                    --preview 'dnf info {}' \
                    --header $'These packages are no longer required\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected orphaned packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD dnf remove -y
                fi
            fi
            ;;
        "zypper")
            packages=$(zypper se --unneeded | awk -F '|' 'NR>5 {print $2}' | tr -d ' ' | \
                fzf --prompt="Orphaned zypper packages: " \
                    --multi \
                    --reverse \
                    --preview 'zypper info {}' \
                    --header $'These packages are no longer required\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected orphaned packages for removal: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD zypper remove -y
                fi
            fi
            ;;
        *)
            echo "Clean orphans is not supported automatically for $PKG_MGR."
            ;;
    esac
}

list_explicit() {
    local packages
    case $PKG_MGR in
        "paru"|"pacman")
            packages=$(pacman -Qeq | \
                fzf --prompt="Explicitly installed: " \
                    --multi \
                    --reverse \
                    --preview 'paru -Si {} 2>/dev/null || pacman -Si {}' \
                    --header $'Packages explicitly installed\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected explicit packages: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs -r $SUDO_CMD pacman -Rs --noconfirm
                fi
            fi
            ;;
        "brew")
            packages=$(brew leaves | \
                fzf --prompt="Explicitly installed brew packages: " \
                    --multi \
                    --reverse \
                    --preview 'brew info {}' \
                    --header $'Packages explicitly installed\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs brew uninstall
                fi
            fi
            ;;
        "apt")
            packages=$(apt-mark showmanual | \
                fzf --prompt="Explicitly installed apt packages: " \
                    --multi \
                    --reverse \
                    --preview 'apt-cache show {}' \
                    --header $'Packages explicitly installed\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD apt-get remove -y
                fi
            fi
            ;;
        "dnf")
            packages=$(dnf repoquery --userinstalled | \
                fzf --prompt="Explicitly installed dnf packages: " \
                    --multi \
                    --reverse \
                    --preview 'dnf info {}' \
                    --header $'Packages explicitly installed\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD dnf remove -y
                fi
            fi
            ;;
        "apk")
            packages=$(cat /etc/apk/world | \
                fzf --prompt="Explicitly installed apk packages: " \
                    --multi \
                    --reverse \
                    --preview 'apk info {}' \
                    --header $'Packages explicitly installed\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD apk del
                fi
            fi
            ;;
        "zypper")
            packages=$(zypper se --installed-only -t package | awk -F '|' 'NR>5 {print $2}' | tr -d ' ' | \
                fzf --prompt="Explicitly installed zypper packages: " \
                    --multi \
                    --reverse \
                    --preview 'zypper info {}' \
                    --header $'Packages explicitly installed\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD zypper remove -y
                fi
            fi
            ;;
        *)
            echo "List explicit is not supported automatically for $PKG_MGR."
            ;;
    esac
}

list_foreign() {
    local packages
    case $PKG_MGR in
        "paru"|"pacman")
            packages=$(pacman -Qmq | \
                fzf --prompt="Foreign packages (AUR/Local): " \
                    --multi \
                    --reverse \
                    --preview 'paru -Si {} 2>/dev/null || pacman -Si {}' \
                    --header $'Packages from AUR or installed locally\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected foreign packages: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs -r $SUDO_CMD pacman -Rs --noconfirm
                fi
            fi
            ;;
        "brew")
            packages=$( (brew list --casks || brew list --cask) 2>/dev/null | \
                fzf --prompt="Installed Homebrew Casks: " \
                    --multi \
                    --reverse \
                    --preview 'brew info {}' \
                    --header $'Cask packages (GUI applications)\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected casks: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs brew uninstall --cask
                fi
            fi
            ;;
        "dnf")
            packages=$(dnf list extras | awk 'NR>1 {print $1}' | \
                fzf --prompt="Extra (non-repo) dnf packages: " \
                    --multi \
                    --reverse \
                    --preview 'dnf info {}' \
                    --header $'Extra packages not in standard repos\nTAB to select multiple\nEnter to remove'
            )
            if [[ -n "$packages" ]]; then
                echo "Selected packages: $packages"
                if confirm_action "Proceed with removal?"; then
                    echo "$packages" | tr '\n' ' ' | xargs $SUDO_CMD dnf remove -y
                fi
            fi
            ;;
        *)
            echo "List foreign/extra is not supported automatically for $PKG_MGR."
            ;;
    esac
}

# Main function
pf() {
    local choice
    choice=$(echo -e "Search & Install\nRemove Packages\nClean Orphans\nList Explicit\nList Foreign\nShow Help" | \
        fzf --prompt="Select action: " --header="Package Management ($PKG_MGR)" --reverse)

    case "$choice" in
        "Search & Install") search_and_install ;;
        "Remove Packages") remove_packages ;;
        "Clean Orphans") clean_orphans ;;
        "List Explicit") list_explicit ;;
        "List Foreign") list_foreign ;;
        "Show Help") show_help ;;
        *) echo "Invalid choice. Exiting."; return 1 ;;
    esac
}
