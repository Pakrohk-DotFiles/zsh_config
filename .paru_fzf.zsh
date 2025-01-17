#!/usr/bin/env zsh

# Function: Display help
show_help() {
    echo -e "\nPackage Management Help:"
    echo "------------------------"
    echo "1. Search & Install (i)  : Search packages from repos and AUR"
    echo "2. Remove Packages (r)   : Remove installed packages"
    echo "3. Clean Orphans (o)     : List and remove orphaned packages"
    echo "4. List Explicit (e)     : Show explicitly installed packages"
    echo "5. List Foreign (f)      : Show AUR/Local packages"
    echo -e "\nUsage Tips:"
    echo "- TAB to select multiple packages"
    echo "- Start typing to search"
    echo "- Ctrl+C to cancel"
    echo "------------------------"
}

# Function: Confirm action
confirm_action() {
    local prompt="$1"
    read -q "REPLY?$prompt [y/N]: " 
    echo # Move to the next line after user input
    [[ "$REPLY" =~ ^[Yy]$ ]]
}

# Function: Search & Install packages
search_and_install() {
    local packages
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
            echo "$packages" | tr '\n' ' ' | xargs -r paru -S --noconfirm --needed
        else
            echo "Installation cancelled."
        fi
    else
        echo "No packages selected."
    fi
}

# Function: Remove packages
remove_packages() {
    local packages
    packages=$(pacman -Qq | \
        fzf --prompt="Select packages to remove: " \
            --multi \
            --reverse \
            --preview 'paru -Si {} 2>/dev/null || pacman -Si {}' \
            --header $'TAB to select multiple packages\nStart typing to search\nEnter to remove'
    )
    if [[ -n "$packages" ]]; then
        echo "Selected packages for removal: $packages"
        if confirm_action "Proceed with removal?"; then
            echo "$packages" | tr '\n' ' ' | xargs -r sudo pacman -Rs --noconfirm
        else
            echo "Removal cancelled."
        fi
    else
        echo "No packages selected."
    fi
}
# Function: Clean orphaned packages
clean_orphans() {
    local packages
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
            echo "$packages" | tr '\n' ' ' | xargs -r sudo pacman -Rs --noconfirm
        else
            echo "Operation cancelled."
        fi
    else
        echo "No orphaned packages selected."
    fi
}
# Function: List explicitly installed packages
list_explicit() {
    local packages
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
            echo "$packages" | tr '\n' ' ' | xargs -r sudo pacman -Rs --noconfirm --needed
        else
            echo "Operation cancelled."
        fi
    else
        echo "No explicit packages selected."
    fi
}

# Function: List foreign packages
list_foreign() {
    local packages
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
            echo "$packages" | tr '\n' ' ' | xargs -r sudo pacman -Rs --noconfirm --needed
        else
            echo "Operation cancelled."
        fi
    else
        echo "No foreign packages selected."
    fi
}

# Main function
pf() {
    local choice
    choice=$(echo -e "Search & Install\nRemove Packages\nClean Orphans\nList Explicit\nList Foreign\nShow Help" | \
        fzf --prompt="Select action: " --header="Package Management" --reverse)

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

