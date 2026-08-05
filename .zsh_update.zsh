#!/bin/zsh

# --- ZSH Config Background Update Checker ---
# Checks for updates in the background and notifies the user only if one is available.

ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.zsh_config}"
LAST_CHECK_FILE="$ZSH_CONFIG_DIR/.last_update_check"
CHECK_INTERVAL=300 # 5 minutes cooldown to avoid redundant fetches

send_notification() {
    local title="Zsh Config Update"
    local msg="A new update is available! Run 'zsh_update' to install."

    # macOS system notification
    if [[ "$(uname)" == "Darwin" ]]; then
        osascript -e "display notification \"$msg\" with title \"$title\"" >/dev/null 2>&1
    # Linux system notification
    elif command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$msg" >/dev/null 2>&1
    fi

    # Terminal message
    echo -e "\n\e[33m[*] A new update is available for your ZSH configuration!\e[0m"
    echo -e "\e[32m[*] Run: \e[34mzsh_update\e[0m to apply the updates automatically!\n"
}

zsh_update() {
    echo -e "\e[34m[*] Updating ZSH configuration...\e[0m"
    cd "$ZSH_CONFIG_DIR"

    # Check if there are any local changes
    local has_changes=0
    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
        has_changes=1
        echo -e "\e[33m[*] Local changes detected. Stashing them temporarily to prevent overwriting...\e[0m"
        git stash -q -m "zsh_update stash before pull on $(date)"
    fi

    echo -e "\e[34m[*] Pulling latest updates from repository...\e[0m"
    if git pull; then
        echo -e "\e[32m[+] ZSH configuration pulled successfully!\e[0m"

        # Restore local changes if stashed
        if (( has_changes )); then
            echo -e "\e[33m[*] Re-applying your local changes...\e[0m"
            if git stash pop -q; then
                echo -e "\e[32m[+] Your local changes have been successfully merged!\e[0m"
            else
                echo -e "\e[31m[!] Warning: Merge conflict detected when applying your local changes.\e[0m"
                echo -e "\e[33m[*] Please review and resolve conflicts in: $ZSH_CONFIG_DIR\e[0m"
            fi
        fi

        echo -e "\e[33m[*] Compiling configurations for maximum speed...\e[0m"
        zsh -c "source $ZSH_CONFIG_DIR/znap/znap.zsh && znap compile $ZSH_CONFIG_DIR"
        echo -e "\e[32m[+] Compilation complete. Please reload your shell with: source ~/.zshrc\e[0m"
    else
        echo -e "\e[31m[!] Failed to pull configuration. Please check your internet connection.\e[0m"
        # If pull failed, restore stash anyway
        if (( has_changes )); then
            echo -e "\e[33m[*] Restoring your local changes...\e[0m"
            git stash pop -q || true
        fi
    fi
}

check_for_updates() {
    # Only check if the directory is a git repository
    [[ -d "$ZSH_CONFIG_DIR/.git" ]] || return

    local current_time=$(date +%s)
    local last_check=0
    [[ -f "$LAST_CHECK_FILE" ]] && last_check=$(cat "$LAST_CHECK_FILE")

    # Check if interval has passed
    if (( current_time - last_check > CHECK_INTERVAL )); then
        # Run the check in the background to avoid blocking the shell
        (
            cd "$ZSH_CONFIG_DIR"
            git fetch -q origin main > /dev/null 2>&1
            local local_hash=$(git rev-parse HEAD)
            local remote_hash=$(git rev-parse origin/main)

            if [[ "$local_hash" != "$remote_hash" ]]; then
                # Create a flag file to notify the user
                touch "$ZSH_CONFIG_DIR/.update_available"
            fi
            echo "$current_time" > "$LAST_CHECK_FILE"
        ) &!
    fi

    # If an update was found, notify the user and remove the flag so they aren't spammed
    if [[ -f "$ZSH_CONFIG_DIR/.update_available" ]]; then
        send_notification
        rm -f "$ZSH_CONFIG_DIR/.update_available"
    fi
}

check_for_updates
