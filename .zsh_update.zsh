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
    if git pull; then
        echo -e "\e[32m[+] ZSH configuration updated successfully!\e[0m"
        echo -e "\e[33m[*] Compiling new configurations for maximum speed...\e[0m"
        zsh -c "source $ZSH_CONFIG_DIR/znap/znap.zsh && znap compile $ZSH_CONFIG_DIR"
        echo -e "\e[32m[+] Compilation complete. Please reload your shell with: source ~/.zshrc\e[0m"
    else
        echo -e "\e[31m[!] Failed to update configuration. Please check your internet connection.\e[0m"
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
