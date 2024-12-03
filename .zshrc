# --- Instant Prompt Initialization (Powerlevel10k) ---
# Enable Powerlevel10k instant prompt. Keep this at the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Path and Environment Setup ---
# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"


setopt NO_BEEP

# Add local binaries and custom paths
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# --- Theme Configuration ---
# Set the theme for Oh My Zsh (Powerlevel10k)
ZSH_THEME="powerlevel10k/powerlevel10k"

# To customize the prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Plugin Configuration ---
# Plugins loaded by Oh My Zsh. Add wisely as too many can slow startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf zsh-history-substring-search zsh-completions docker docker-compose)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# --- FZF Keybindings and Completions ---
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# --- Zsh Autocompletion Enhancements ---
# Enable Zsh's autocompletion system
autoload -Uz compinit
compinit


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
