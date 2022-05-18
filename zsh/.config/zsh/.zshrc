# Disable beeps
unsetopt BEEP

# Disable vi mode


# Files to source
source $ZDOTDIR/zsh-exports
source $ZDOTDIR/zsh-aliases
source $ZDOTDIR/zsh-functions
source $ZDOTDIR/zsh-prompt
source $ZDOTDIR/zsh-keybindings

# History settings
HISTFILE=$XDG_CACHE_HOME/.zhistory        # Where to save history to disk
HISTSIZE=10000                              # How many lines of history to keep in memory
SAVEHIST=10000                              # Number of history entries to save to disk
HISTDUP=erase                               # Erase duplicates in the history file
setopt    hist_ignore_all_dups    # Erase oldest dupliate
setopt    appendhistory           # Append history to the history file
setopt    sharehistory            # Share history across terminals
setopt    incappendhistory        # Immediately append to the history file

# Load module
zmodload -a zsh/mapfile mapfile

# Load plugins
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/plugins/zsh-quotes/zsh-quotes.zsh

# Completions
autoload -Uz compinit && compinit
fpath=($HOME/.config/zsh/completions $fpath)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Run scripts
echo ${(%):-%F{magenta}}${quoter_selection[RANDOM % ${#quoter_selection} + 1]}${(%):-%f}
unset quoter_selection






