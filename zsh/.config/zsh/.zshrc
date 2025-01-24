#~~~~ ZSH options ~~~~

# Disable vi mode



# Disable beeps
unsetopt BEEP

# Globbing
setopt EXTENDED_GLOB
setopt NULL_GLOB
setopt GLOBDOTS
setopt NO_CASE_GLOB
setopt GLOB_COMPLETE

# Correction 
setopt AUTO_CD
setopt CORRECT
setopt CORRECT_ALL

# History
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_SPACE 
setopt HIST_EXPIRE_DUPS_FIRST 
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
HISTFILE=$XDG_CACHE_HOME/zsh/history
HISTDUP=erase                               # Erase duplicates in the history file
HISTSIZE=100000
SAVEHIST=100000

# ~~~~~~ EXPORTS ~~~~~~
export AZURE_CONFIG_DIR=$XDG_CONFIG_HOME/azure
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/config.toml
path=(
  $path
  $HOME/.local/bin
  $HOME/.cargo/bin
)
typeset -U path
path=($^path(N-/))
export PATH

# ~~~~~~ LOAD MODULES  ~~~~~~
zmodload -a zsh/mapfile mapfile

# ~~~~~~ PLUGINS AND FUNCTIONS  ~~~~~~
# source <(fzf --zsh) Supported in version > 0.48.0  
source $ZDOTDIR/plugins/zsh-quotes/zsh-quotes.zsh
source $ZDOTDIR/plugins/zsh-extract/extract.plugin.zsh
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fpath=($ZDOTDIR/functions $fpath)

# ~~~~~~ COMPLETION ~~~~~~
autoload -Uz compinit && compinit
zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)--color=auto}"                        # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
fpath=($ZDOTDIR/completions $fpath)
# Azure cli completion 
autoload -U +X bashcompinit && bashcompinit
source $ZDOTDIR/completions/*

# ~~~~~~ EXPORTS ~~~~~~
# User-specific tools
path=(
  $path
  $HOME/.local/bin
  $HOME/.cargo/bin
)

# Deduplicate and export
typeset -U path
path=($^path(N-/))
export PATH

# Dynamically fetch the distro (relevant in terminal sessions)
export DISTRO=$(awk -F '=' '/^ID=/ {print $2}' /etc/*-release)

# ~~~ ALIASES ~~~
alias ls="eza --icons --group-directories-first -la"
alias vim="nvim"
alias history="history -i"
alias git-clean-main="git checkout main && git branch -D \$(git branch | grep -v 'main') && git fetch && git remote prune origin && git pull"

# ~~~~~~ KEY BINDINGS ~~~~~~
bindkey -e  # Set Emacs key bindings (default)
bindkey "^[[H"  beginning-of-line # Home
bindkey "^[[F"  end-of-line # End
bindkey "^[[3~" delete-char # Delete
bindkey "^[[1;5D" backward-word # Ctrl + Left
bindkey "^[[1;5C" forward-word # Ctrl + Right
stty -ixon # Disable flow control
unsetopt BEEP # Disable beep

# ~~~ PROMPT ~~~
autoload colors && colors
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
# echo ${(%):-%F{magenta}}$(quotes)${(%):-%f}
echo ${(%):-%F{magenta}}${quoter_selection[RANDOM % ${#quoter_selection} + 1]}${(%):-%f}
