#!/usr/bin/env bash
set -e 

export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state
export XDG_RUNTIME_DIR=/run/user/$UID
export WGETRC=$XDG_CONFIG_HOME/wgetrc
export GIT_CONFIG=$XDG_CONFIG_HOME/git/config
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/config.toml

apt_packages="curl exa fzf git neovim stow zsh bat jq"
#apt_packages_optional="python python-pip whois ipcalc bind nmap docker terraform kubectl rust"
apt_packages_optional=""

pacman_packages="curl exa fzf git neovim stow zsh bat jq"
#pacman_packages_optional="python python-pip whois ipcalc bind nmap docker terraform kubectl rust"
pacman_packages_optional=""

###############################################################################
# Detect OS and distro type
###############################################################################

function no_system_packages() {
cat << EOF
System package installation isn't supported with your distro.
Please install any dependent packages on your own. You can view the list at:
    https://raw.githubusercontent.com/crankiz/dotfiles/main/install.sh
Then re-run the script and explicitly skip installing system packages:
    bash <(curl -sS https://raw.githubusercontent.com/crankiz/dotfiles/main/install.sh) --skip-system-packages
EOF

exit 1
}

###############################################################################
# Install packages using your distro package manager
###############################################################################

distro=$(awk -F '=' '/^ID=/ {print $2}' /etc/*-release)

function apt_install_packages {
    # shellcheck disable=SC2086
    sudo apt-get update && sudo apt-get install -y ${apt_packages} ${apt_packages_optional}
}

function pacman_install_packages {
    # shellcheck disable=SC2086
    sudo pacman -Syyu && sudo pacman -Syyu ${pacman_packages} ${pacman_packages_optional}
}

function display_packages {
    if [ "${distro}" == "ubuntu" ]; then
        echo "${apt_packages} ${apt_packages_optional}"
    elif [ "${distro}" == "arch" ]; then
        echo "${pacman_packages} ${pacman_packages_optional}"
    else
        no_system_packages
    fi
}

if [ -z "${skip_system_packages}" ]; then
cat << EOF
If you choose yes, all of the system packages below will be installed:
$(display_packages)
If you choose no, the above packages will not be installed and this script
will exit. This gives you a chance to edit the list of packages if you don't
agree with any of the decisions.
The packages listed after zsh are technically optional but are quite useful.
Keep in mind if you don't install pwgen you won't be able to generate random
passwords using a custom alias that's included in these dotfiles.
EOF
    while true; do
        read -rp "Do you want to install the above packages? (y/n) " yn
        case "${yn}" in
            [Yy]*)
                if [ "${distro}" == "ubuntu" ]; then
                    apt_install_packages
                elif [ "${distro}" == "arch" ]; then
                    pacman_install_packages
                else
                    no_system_packages
                fi

                break;;
            [Nn]*) exit 0;;
            *) echo "Please answer y or n";;
        esac
    done
else
    echo "System package installation was skipped!"
fi

###############################################################################
# Clone dotfiles
###############################################################################

read -rep $'\nWhere do you want to clone these dotfiles to [~/.dotfiles]? ' clone_path
clone_path="${clone_path:-"${HOME}/.dotfiles"}"

# Ensure path doesn't exist.
while [ -e "${clone_path}" ]; do
    read -rep $'\nPath exists, try again? (y) ' y
    case "${y}" in
        [Yy]*)

            break;;
        *) echo "Please answer y or CTRL+c the script to abort everything";;
    esac
done

git clone https://github.com/crankiz/dotfiles "${clone_path}"

###############################################################################
# Stow dotfiles
###############################################################################

cd "${clone_path}"
stow --ignore=install.sh ./*

###############################################################################
# Install zsh plugins and auto completion
###############################################################################

$HOME/.local/bin/update-zsh-plugins

git_raw="https://raw.githubusercontent.com"

curl ${git_raw}/chubin/cheat.sh/master/share/zsh.txt \
    --create-dirs \
    -o $XDG_CONFIG_HOME/zsh/completions/_cht

curl ${git_raw}/zsh-users/zsh-completions/master/src/_openssl \
    --create-dirs \
    -o $XDG_CONFIG_HOME/zsh/completions/_openssl

curl ${git_raw}/ogham/exa/master/completions/zsh/_exa \
    --create-dirs \
    -o  $XDG_CONFIG_HOME/zsh/completions/_exa

###############################################################################
# Install Plug (Vim plugin manager)
###############################################################################

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

###############################################################################
# Install Vim plugins
###############################################################################

printf "\n\nInstalling Vim plugins...\n"
nvim -E +PlugInstall +qall || true

###############################################################################
# Change default shell to zsh
###############################################################################

chsh -s "$(command -v zsh)"

###############################################################################
# Done!
###############################################################################

cat << EOF
Everything was installed successfully!
You can safely close this terminal.
The next time you open your terminal zsh will be ready to go!
EOF

exit 0
