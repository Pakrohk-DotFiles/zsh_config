#!/bin/zsh

# --- ZSH Config Background Update Checker ---
# Checks for updates in the background and notifies the user only if one is available.

ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.zsh_config}"
UPDATE_LOG="$ZSH_CONFIG_DIR/.update_check.log"
LAST_CHECK_FILE="$ZSH_CONFIG_DIR/.last_update_check"
CHECK_INTERVAL=86400 # 24 hours in seconds

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
                # Create a flag file to notify the user on the next shell start
                touch "$ZSH_CONFIG_DIR/.update_available"
            fi
            echo "$current_time" > "$LAST_CHECK_FILE"
        ) &!
    fi

    # If an update was found in a previous check, notify the user
    if [[ -f "$ZSH_CONFIG_DIR/.update_available" ]]; then
        echo -e "\n\e[33m[*] A new update is available for your ZSH configuration!\e[0m"
        echo -e "\e[32m[*] Run: \e[34mcd $ZSH_CONFIG_DIR && git pull\e[0m\n"
        # Optional: auto-remove the flag after notification or keep until updated
        rm "$ZSH_CONFIG_DIR/.update_available"
    fi
}

check_for_updates
