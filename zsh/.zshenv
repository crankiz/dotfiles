# ~~~~~~ EXPORTS ~~~~~~
# ZSH-specific environment variables
export ZDOTDIR=$HOME/.config/zsh
# XDG Base Directory Specification
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_RUNTIME_DIR=/run/user/$UID
export XDG_STATE_HOME=$HOME/.local/state
# Default environment variables
export TERM='xterm-256color'
export EDITOR='nvim'
export MANPAGER='nvim +Man!'
# Development tools and configuration
export GIT_CONFIG=$XDG_CONFIG_HOME/git/config
export CARGO_HOME=$XDG_DATA_HOME/cargo
export DOCKER_CONFIG=$XDG_CONFIG_HOME/docker
export VSCODE_PORTABLE=$XDG_DATA_HOME/vscode
export WGETRC=$XDG_CONFIG_HOME/wgetrc
# Azure and Starship configurations
export AZURE_CONFIG_DIR=$XDG_CONFIG_HOME/azure
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/config.toml
# Word characters modification (applies to all shells)
export WORDCHARS=${WORDCHARS/\/}
# Theme for applications
export BAT_THEME="gruvbox-dark"


# ~~~~~~ PATHS ~~~~~~
# Core paths for system-wide tools and Go
export PATH=$HOME/.local/bin:$HOME/.dotnet:$HOME/.dotnet/tools:/usr/local/go/bin:$PATH

# Go-specific paths
export GOPATH=$XDG_DATA_HOME/go
export GOMODCACHE=$XDG_CACHE_HOME/go/mod
export GOBIN="$HOME/.local/bin"