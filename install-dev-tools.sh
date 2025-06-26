#!/bin/bash

# run_once_install-dev-tools.sh
# Declare apps to install and run

set -e

# Apps to install - edit this array to add/remove tools
APPS=(
    "nvim"
    "lazygit"
    "atuin"
    "mise"
    "starship"
    "zoxide"
    "bat"
    "ripgrep"
    "fd"
    "fzf"
    "navi"
    "eza"
    "alacritty"
    "zellij"
    "chezmoi"
)

# Get OS type
get_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    elif command -v apt >/dev/null 2>&1; then
        echo "debian"
    else
        echo "❌ Unsupported OS. This script only supports macOS and Debian-based Linux distributions (Ubuntu, Mint, etc.)" >&2
        exit 1
    fi
}

echo "🔧 Installing dev tools..."

# Ensure ~/.local/bin exists
mkdir -p ~/.local/bin

# Detect and show OS
OS=$(get_os)
echo "🖥️  Detected OS: $OS"

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Neovim installers
install_nvim_mac() {
    brew install neovim
}

install_nvim_debian() {
    curl -Lo nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    tar xf nvim.tar.gz
    cp -r nvim-linux-x86_64/* ~/.local/
    rm -rf nvim.tar.gz nvim-linux-x86_64
}

# Lazygit installers
install_lazygit_mac() {
    brew install lazygit
}

install_lazygit_debian() {
    if sudo apt install -y lazygit 2>/dev/null; then
        echo "✅ lazygit installed via apt"
    else
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit -D -t /usr/local/bin/
        rm -f lazygit.tar.gz lazygit
    fi
}

# Generic installers (same for all platforms)
install_atuin() {
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | bash
}

install_mise() {
    curl https://mise.run | sh
}

install_starship() {
    curl -sS https://starship.rs/install.sh | sh
}

install_zoxide() {
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
}

install_navi() {
    bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)
}

# Bat installers (OS-specific due to different package names)
install_bat_mac() {
    brew install bat
}

install_bat_debian() {
    sudo apt install -y bat
    # Create symlink since Ubuntu package installs as batcat
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat 2>/dev/null || true
}

# Ripgrep installers (OS-specific)
install_ripgrep_mac() {
    brew install ripgrep
}

install_ripgrep_debian() {
    sudo apt install -y ripgrep
}

# Fd installers (OS-specific due to different package names)
install_fd_mac() {
    brew install fd
}

install_fd_debian() {
    sudo apt install -y fd-find
    # Create symlink since Ubuntu package installs as fdfind
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/fdfind ~/.local/bin/fd 2>/dev/null || true
}

# Fzf installers (OS-specific)
install_fzf_mac() {
    brew install fzf
}

install_fzf_debian() {
    sudo apt install -y fzf
}

# Eza installers (OS-specific)
install_eza_mac() {
    brew install eza
}

install_eza_debian() {
    if sudo apt install -y eza 2>/dev/null; then
        echo "✅ eza installed via apt"
    else
        # Fallback to GitHub release
        EZA_VERSION=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
        curl -Lo eza.tar.gz "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
        tar xf eza.tar.gz
        sudo install eza /usr/local/bin/
        rm -f eza.tar.gz eza
    fi
}

# Alacritty installers (OS-specific)
install_alacritty_mac() {
    brew install --cask alacritty
}

install_alacritty_debian() {
    sudo apt install -y alacritty
}

# Zellij installers (OS-specific)
install_zellij_mac() {
    brew install zellij
}

install_zellij_debian() {
    curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /tmp
    sudo mv /tmp/zellij /usr/local/bin/
}

# Chezmoi installers (OS-specific due to install location)
install_chezmoi_mac() {
    brew install chezmoi
}

install_chezmoi_debian() {
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
}

# Generic installer function
install_tool() {
    local tool=$1
    local os=$(get_os)
    local os_func_name="install_${tool}_${os}"
    local generic_func_name="install_${tool}"

    # Map tool names to command names
    local cmd_name="$tool"
    case "$tool" in
        "ripgrep") cmd_name="rg" ;;
        "fd") cmd_name="fd" ;;
        "bat") cmd_name="bat" ;;
    esac

    if ! command_exists "$cmd_name"; then
        echo "📦 Installing $tool..."
        # Try OS-specific function first
        if declare -f "$os_func_name" >/dev/null; then
            "$os_func_name"
        # Fallback to generic function
        elif declare -f "$generic_func_name" >/dev/null; then
            "$generic_func_name"
        else
            echo "❌ No installer for $tool"
            return 1
        fi
    else
        echo "✅ $tool already installed"
    fi
}

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "🛤️  Adding ~/.local/bin to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
fi

# Install all apps from array
for app in "${APPS[@]}"; do
    install_tool "$app"
done

echo "🎉 Done!"