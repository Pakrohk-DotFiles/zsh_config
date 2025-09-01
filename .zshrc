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

# Example minimal builtin function (mkcd stays here as it's too common)
mkcd() { mkdir -p "$1" && cd "$1"; }

# Cheat.sh integration
cheat() { curl -s cheat.sh/"$1"; }

########################################
# External Configs
########################################
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.paru_fzf.zsh ] && source ~/.paru_fzf.zsh

# Dart completion
[ -f ~/.config/.dart-cli-completion/zsh-config.zsh ] && source ~/.config/.dart-cli-completion/zsh-config.zsh

########################################
# Fallback for custom functions
########################################
fpath+=~/.zfunc
autoload -Uz compinit
compinit

# Check and start SSH Agent automatically in the background
function ensure_ssh_agent() {
  # Check if SSH Agent is running
  if [[ -z "$SSH_AUTH_SOCK" ]] || ! ssh-add -l >/dev/null 2>&1; then
    # Start SSH Agent in the background and suppress output
    eval "$(ssh-agent -s)" >/dev/null 2>&1 &
    # Add SSH key (replace with your key path if different)
    ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1
  fi
}

# Run the function automatically when Zsh starts
ensure_ssh_agent
########################################
# End of ~/.zshrc
########################################

