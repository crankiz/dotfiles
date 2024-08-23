#!/usr/bin/env bash

###############################################################################
# Set up Environment
###############################################################################

# Define variables
export XDG_CONFIG_HOME=$HOME/.config
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

repo_url="https://github.com/crankiz/dotfiles"
# Dotfiles location
target_folder="$HOME/.dotfiles"
# List of packages to check and install
packages=("curl" "eza" "fzf" "git" "neovim" "stow" "zsh" "bat" "jq")

###############################################################################
# Check if the script is run as root
###############################################################################

if [ "$EUID" -ne 0 ]; then
    SUDO="sudo -H"
else
    SUDO=""
fi

###############################################################################
# Function to check if a package is installed
###############################################################################

is_package_installed() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# Function to install packages using the appropriate package manager
###############################################################################

install_packages() {
    local package_manager

    # Check which package manager is available
    if is_package_installed "apt"; then
        package_manager="$SUDO apt install -y"
    elif is_package_installed "dnf"; then
        package_manager="$SUDO dnf install -y"
    elif is_package_installed "yum"; then
        package_manager="$SUDO yum install -y"
    elif is_package_installed "pacman"; then
        package_manager="$SUDO pacman -Sy --noconfirm"
    elif is_package_installed "apk"; then
        package_manager="$SUDO apk add"
    else
        echo "Error: Unsupported package manager. Please install the packages manually."
        exit 1
    fi

    # Install missing packages
    for package in "${packages[@]}"; do
        if ! is_package_installed "$package"; then
            echo "Installing $package..."
            $package_manager "$package" || {
                echo "Error: Failed to install $package."
                exit 1
            }
        else
            echo "$package is already installed."
        fi
    done
}

###############################################################################
# Call the install_packages function
###############################################################################

install_packages
echo "Package installation complete."

###############################################################################
# Clone and Stow Dotfiles
###############################################################################

# Check if the cloning was successful
if git clone --recurse-submodules "$repo_url" "$target_folder"; then
    echo "Repository cloned successfully."
    # Change to the dotfiles directory
    cd "$target_folder" || exit
    # Use GNU Stow to create symlinks
    stow -t ~ */
    echo "Symlinks created successfully."
else
    echo "Error: Cloning failed."
fi

###############################################################################
# Install zsh plugins and auto completion
###############################################################################

# Function to download a file using curl
get_auto_completion() {
    local url="$1"
    local target_path="$2"

    # Ensure the directory exists or create it
    mkdir -p "$(dirname "$target_path")"

    echo "Downloading $url to $target_path..."
    curl -fsSL "$url" --create-dirs -o "$target_path"

    if [ $? -eq 0 ]; then
        echo "Download successful."
    else
        echo "Error: Download failed."
    fi
}

git_raw="https://raw.githubusercontent.com"

get_auto_completion "${git_raw}/chubin/cheat.sh/master/share/zsh.txt" "$ZDOTDIR/completions/_cht"
get_auto_completion "${git_raw}/zsh-users/zsh-completions/master/src/_openssl" "$ZDOTDIR/completions/_openssl"
get_auto_completion "${git_raw}/eza-community/eza/main/completions/zsh/_eza" "$ZDOTDIR/completions/_eza"

###############################################################################
# Install starship
###############################################################################

command -v starship > /dev/null || curl -sS https://starship.rs/install.sh | sh

###############################################################################
# Install Plug (Vim plugin manager)
###############################################################################

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

###############################################################################
# Install Vim plugins
###############################################################################

# Ensure the directory exists or create it
echo -e "\n\nInstalling Vim plugins..."
nvim -E +PlugInstall +qall || true

###############################################################################
# Change default shell to zsh
###############################################################################

$SUDO chsh -s $(which zsh) $SUDO_USER

###############################################################################
# Completion Message
###############################################################################

cat << EOF
Everything was installed successfully!
You can safely close this terminal.
The next time you open your terminal, zsh will be ready to go!
EOF

exit 0
