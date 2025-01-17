# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Download Znap, if it's not there yet.
[[ -r ~/.zsh_config/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/.zsh_config/znap
source ~/.zsh_config/znap/znap.zsh  # Start Znap

# ZSH options
setopt AUTO_PUSHD
setopt AUTO_CD
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Key bindings
# bindkey -v
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# Completion configuration
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

# Prompt
znap source romkatv/powerlevel10k

# Plugins
znap source zdharma-continuum/fast-syntax-highlighting
znap source zsh-users/zsh-autosuggestions
znap source marlonrichert/zcolors
znap source mfaerevaag/wd
znap source ohmyzsh/ohmyzsh plugins/git
znap source djui/alias-tips
znap source ohmyzsh/ohmyzsh plugins/colored-man-pages
znap source ohmyzsh/ohmyzsh plugins/virtualenvwrapper

# Install and load z
znap source rupa/z

# Evaluate zcolors
znap eval zcolors "zcolors ${(q)LS_COLORS}"

# Editor configuration
export EDITOR='nvim'

# Aliases
alias vi='nvim'
alias ls='ls --color=auto -la'
alias grep='grep --color=auto'
alias refonts='sudo fc-cache -f -r -v'
alias softar='sudo pacman -Rn $(pacman -Qdtq)'
alias p='paru'
alias ar='sudo pacman -Rsn $(pacman -Qdtq)'
alias upgk="sudo mkinitcpio -P && sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias upg="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias upk="sudo mkinitcpio -P"
alias AReboot='systemctl --user restart pipewire && systemctl --user daemon-reload'
alias DAReboot='killall Discord && ((discord &) &>/dev/null) && AReboot'
alias reflectmirrors='sudo reflector --country "France,Iran" -l 10 --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && cat /etc/pacman.d/mirrorlist'
alias repack_arch='pacman -Qnq | sudo pacman -Sy - '

# Functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Cheat.sh integration
function cheat() {
    curl cheat.sh/"$1"
}

# Dart completion (if needed)
[[ -f /home/ali/.config/.dart-cli-completion/zsh-config.zsh ]] && source /home/ali/.config/.dart-cli-completion/zsh-config.zsh

# Load any local configurations
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.paru_fzf.zsh ]] && source ~/.paru_fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh




fpath+=~/.zfunc; autoload -Uz compinit; compinit
