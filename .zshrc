# --- Kitty remote-control env (works with keepalive + Niri) ---
# If we're running inside Kitty and RC var is missing, point it to the user socket.
if [[ "$TERM" == "xterm-kitty" && -z "$KITTY_LISTEN_ON" ]]; then
  export KITTY_LISTEN_ON="unix:${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/kitty.sock"
fi
# --- Instant Prompt (first, and keep quiet to avoid warnings) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# --- Oh My Zsh core (no OMZ-managed plugins from system packages) ---
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Don’t use OMZ’s theme loader; source the packaged theme directly
ZSH_THEME=""
if [[ -r /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
elif [[ -r /usr/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /usr/share/powerlevel10k/powerlevel10k.zsh-theme
fi
[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Load only OMZ’s built-in plugins here
plugins=(git fzf docker docker-compose)
source "$ZSH/oh-my-zsh.sh"

# --- System plugins from pacman (source directly) ---
# autosuggestions (before highlighting)
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# history substring search
[[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# extra completions (extend fpath)
if [[ -d /usr/share/zsh/plugins/zsh-completions ]]; then
  fpath=(/usr/share/zsh/plugins/zsh-completions $fpath)
fi

# syntax highlighting MUST be last
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf keybindings/completions from package
[[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -r /usr/share/fzf/completion.zsh   ]] && source /usr/share/fzf/completion.zsh

# ensure completion system is initialized
autoload -Uz compinit
compinit -u


# Additional completion tweaks
zstyle ':completion:*' menu select                    # Enable menu-based completion
zstyle ':completion:*' descriptions format '%B%d%b'  # Show completion descriptions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # Case-insensitive completion
zstyle ':completion:*:default' list-prompt '%S%M matches%s'  # Display match count
zstyle ':completion:*' file-patterns '*:all-files'   # Complete hidden files

# --- Vim Mode ---
# Enable Vim mode for Zsh
bindkey -v  # Enable Vim mode
export KEYTIMEOUT=1  # Reduce delay for escape sequences
# Customize keybindings in Vim mode
bindkey '^P' up-line-or-search  # Search history with up arrow
bindkey '^N' down-line-or-search  # Search history with down arrow

# --- User Configuration ---
# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL='nvim'

# Add personal aliases here or in $ZSH_CUSTOM/aliases.zsh
# alias zshconfig="nvim ~/.zshrc"
# alias ohmyzsh="nvim ~/.oh-my-zsh"

# Aliases for `exa` with icons and colors
alias ls="exa --icons"
alias la="exa --icons -a"       # Show hidden files
alias ll="exa --icons -la"      # Long format with hidden files
alias lt="exa --icons --tree"   # Display a tree view


# shorhand aliases
alias v="nvim"
alias c="cd"
alias lp="~/dotfiles/bash/hyperland/load-project.sh"
alias vpnc="/home/mastermind/dotfiles/bash/misc/vpn_connect.sh"
alias vpnd="/home/mastermind/dotfiles/bash/misc/vpn_disconnect.sh"
alias treecp="tree -I 'node_modules|dist|target' | wl-copy"
alias ssh='kitty +kitten ssh'
alias kthemes='kitty +kitten themes'
alias vial='/home/mastermind/app_image_lib/Vial-v0.7.1-x86_64.AppImage'

# function to git add all and commit with specified message
gac() {
  git add . && git commit -m "$1"
}

# move to bin
# newterm() {
#   kitty --detach --working-directory "$(pwd)"
# }

# --- Optional Settings ---
# Uncomment the following as needed:
# export LANG=en_US.UTF-8           # Set language environment
# export MANPATH="/usr/local/man:$MANPATH"  # Set manual page path

# --- Advanced Configuration ---
# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# bun completions
[ -s "/home/mastermind/.bun/_bun" ] && source "/home/mastermind/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"

export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XKB_DEFAULT_LAYOUT="us,ru"
export GTK_THEME=gruvbox-dark-gtk
export GTK_ICON_THEME=Colloid-Gruvbox
export XCURSOR_THEME="Colloid-Gruvbox"

