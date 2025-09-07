########################################
# ~/.zshrc - Complete ZSH Configuration
########################################
### --- Bootstrap Znap ---
[[ -r ~/.zsh_config/znap/znap.zsh ]] || git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~/.zsh_config/znap
source ~/.zsh_config/znap/znap.zsh

########################################
# ZSH Options
########################################
setopt AUTO_PUSHD
setopt AUTO_CD
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

########################################
# History
########################################
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

########################################
# Key Bindings
########################################
# bindkey -v  # vi-mode if you prefer
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^R' history-incremental-search-backward
bindkey '^P' up-line-or-search
bindkey '^N' down-line-or-search

########################################
# Completion
########################################
znap source zsh-users/zsh-completions
autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:descriptions' format '%F{yellow}%B%d%b%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' complete-options true
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' rehash true
ENABLE_CORRECTION="true"

########################################
# Prompt / Theme
########################################
[ -f ~/.prompt.local ] && source ~/.prompt.local
znap prompt

########################################
# Plugins
########################################
znap source zdharma-continuum/fast-syntax-highlighting
znap source zsh-users/zsh-autosuggestions
znap source marlonrichert/zcolors
znap source mfaerevaag/wd
znap source ohmyzsh/ohmyzsh plugins/git
znap source djui/alias-tips
znap source ohmyzsh/ohmyzsh plugins/colored-man-pages
znap source ohmyzsh/ohmyzsh plugins/virtualenvwrapper
znap source rupa/z

# Evaluate zcolors
znap eval zcolors "zcolors ${(q)LS_COLORS}"

########################################
# Environment
########################################
export EDITOR='nvim'
export BROWSER='firefox'
export TERMINAL='kitty'
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

########################################
# Aliases & Functions
########################################
# Keep the main config clean
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
########################################
# External Configs
########################################
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.paru_fzf.zsh ] && source ~/.paru_fzf.zsh

# Dart completion
[ -f ~/.config/.dart-cli-completion/zsh-config.zsh ] && source ~/.config/.dart-cli-completion/zsh-config.zsh

########################################
# Evals
########################################


########################################
# SSH Agent Management (Zsh Compatible)
# - Starts ssh-agent if not already running
# - Reuses environment across sessions
# - Loads key only once to avoid repeated passphrase prompts
########################################

SSH_ENV="$HOME/.ssh/agent-environment"

# Start a new ssh-agent and save its environment variables
start_agent() {
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
    chmod 600 "$SSH_ENV"
    . "$SSH_ENV" >/dev/null
}

# Add private key if agent has no keys loaded
load_keys() {
    if ! ssh-add -l >/dev/null 2>&1; then
        ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
    fi
}

# Restore existing agent environment if available
if [[ -f "$SSH_ENV" ]]; then
    . "$SSH_ENV" >/dev/null
    if ! kill -0 "$SSH_AGENT_PID" >/dev/null 2>&1; then
        start_agent
    fi
else
    start_agent
fi

# Ensure environment is valid
if [[ -z "$SSH_AUTH_SOCK" ]] || ! kill -0 "$SSH_AGENT_PID" >/dev/null 2>&1; then
    start_agent
fi

# Load keys only if necessary
load_keys

########################################
# Fallback for custom functions
########################################
fpath+=~/.zfunc
autoload -Uz compinit
compinit

########################################
# End of ~/.zshrc
########################################

