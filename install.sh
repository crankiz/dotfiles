#!/usr/bin/env bash
# Install packages
# List of packages to install
packages=(
    apt-transport-https
    ca-certificates
    lsb-release
    curl
    gpg
    gnupg
    git
    stow
    neovim
    zsh
    fzf
    bat
    zoxide  
)

# Loop through the list of packages and install if not already installed
for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        echo "Installing $package..."
        sudo apt install -y $package || { echo "Failed to install $package"; exit 1; }
    else
        echo "$package is already installed."
    fi
done

# Add repositories
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://apt.fury.io/wez/gpg.key                                  | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --yes --dearmor -o /etc/apt/keyrings/gierens.gpg
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc                | sudo gpg --yes --dearmor -o /etc/apt/keyrings/microsoft.gpg

echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo tee /etc/apt/sources.list.d/azure-cli.sources > /dev/null <<EOL
Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: $(lsb_release -cs)
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg
EOL

sudo chmod 644 /etc/apt/keyrings/*.gpg

sudo apt update

# Install packages from the added repositories
sudo apt install -y wezterm eza azure-cli

# Install zsh puligins
ZDOTDIR=$HOME/.config/zsh
plugins=(
    git@github.com:le0me55i/zsh-extract.git
    git@github.com:zsh-users/zsh-autosuggestions.git
    git@github.com:zsh-users/zsh-syntax-highlighting.git
)
for repo in "${plugins[@]}"; do
    dir="$ZDOTDIR/plugins/$(basename "${repo}" .git)"
    git clone "${repo}" "${dir}"
    rm -rf "${dir}/.git"
done

# Install completions
completions=(
    https://raw.githubusercontent.com/le0me55i/zsh-extract/refs/heads/master/_extract
    https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion
)
for url in "${completions[@]}"; do
    file=$(basename $url)
    curl --output "zsh/.config/zsh/completions/_${file#_}" ${url}
done 

# Install starship
curl -sS https://starship.rs/install.sh | sh

# Install layvim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Install fonts
declare -a fonts=(
    FiraMono
    JetBrainsMono
    OpenDyslexic
    UbuntuMono
)

fontVersion="3.2.1"
fontsDir="$HOME/.local/share/fonts"

for font in "${fonts[@]}"; do
    zipFile="${font}.zip"
    fontUrl="https://github.com/ryanoasis/nerd-fonts/releases/download/v${fontVersion}/${zipFile}"
    echo "Downloading ${fontUrl}"
    curl -O "$fontUrl"
    unzip "${zipFile}" -d "${fontsDir}"
    rm "${zipFile}"
done

# Install go
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz

# Install az-pim-cli
git clone https://github.com/netr0m/az-pim-cli.git
go build -C az-pim-cli -o ~/.local/bin
rm -rf az-pim-cli

# Install dotnet
curl -L -O https://download.visualstudio.microsoft.com/download/pr/308f16a9-2ecf-4a42-b8bb-c1233de985fd/be6e87045ab21935bd8bb98ce69026c4/dotnet-sdk-9.0.100-linux-x64.tar.gz
DOTNET_FILE=dotnet-sdk-9.0.100-linux-x64.tar.gz
export DOTNET_ROOT=${HOME}/.dotnet
mkdir -p "$DOTNET_ROOT" && tar zxf "$DOTNET_FILE" -C "$DOTNET_ROOT"
