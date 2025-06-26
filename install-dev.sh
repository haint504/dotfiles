#!/bin/bash

# Development Tools Auto-Installer
# Compatible with macOS and Ubuntu-based Linux distributions
# Tools: atuin, mise, starship, zoxide, bat, ripgrep, fd-find, fzf, navi, eza, alacritty, zellij

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]] || [[ "$ID_LIKE" == *"ubuntu"* ]] || [[ "$ID_LIKE" == *"debian"* ]]; then
            echo "ubuntu"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Function to install tools on macOS
install_macos() {
    print_status "Installing tools on macOS using Homebrew..."

    # Check if Homebrew is installed
    if ! command_exists brew; then
        print_status "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Update Homebrew
    print_status "Updating Homebrew..."
    brew update

    # Install tools
    local tools=(
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
    )

    for tool in "${tools[@]}"; do
        if command_exists "$tool" || command_exists "${tool/fd/fd}"; then
            print_warning "$tool is already installed, skipping..."
        else
            print_status "Installing $tool..."
            brew install "$tool"
            print_success "$tool installed successfully"
        fi
    done
}

# Function to install tools on Ubuntu
install_ubuntu() {
    print_status "Installing tools on Ubuntu/Debian..."

    # Update package list
    print_status "Updating package list..."
    sudo apt update

    # Install available packages from apt
    local apt_tools=("bat" "ripgrep" "fd-find" "fzf")

    for tool in "${apt_tools[@]}"; do
        if dpkg -l | grep -q "^ii  $tool "; then
            print_warning "$tool is already installed, skipping..."
        else
            print_status "Installing $tool via apt..."
            sudo apt install -y "$tool"
            print_success "$tool installed successfully"
        fi
    done

    # Install zoxide
    if command_exists zoxide; then
        print_warning "zoxide is already installed, skipping..."
    else
        print_status "Installing zoxide..."
        if ! sudo apt install -y zoxide 2>/dev/null; then
            print_warning "zoxide not available in apt, installing via curl..."
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        fi
        print_success "zoxide installed successfully"
    fi

    # Install atuin
    if command_exists atuin; then
        print_warning "atuin is already installed, skipping..."
    else
        print_status "Installing atuin..."
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
        print_success "atuin installed successfully"
    fi

    # Install mise
    if command_exists mise; then
        print_warning "mise is already installed, skipping..."
    else
        print_status "Installing mise..."
        curl https://mise.run | sh
        print_success "mise installed successfully"
    fi

    # Install starship
    if command_exists starship; then
        print_warning "starship is already installed, skipping..."
    else
        print_status "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh
        print_success "starship installed successfully"
    fi

    # Install eza
    if command_exists eza; then
        print_warning "eza is already installed, skipping..."
    else
        print_status "Installing eza..."
        # Add eza repository
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
        print_success "eza installed successfully"
    fi

    # Install navi
    if command_exists navi; then
        print_warning "navi is already installed, skipping..."
    else
        print_status "Installing navi..."
        BIN_DIR=/usr/local/bin bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)
        print_success "navi installed successfully"
    fi

    # Install alacritty
    if command_exists alacritty; then
        print_warning "alacritty is already installed, skipping..."
    else
        print_status "Installing alacritty..."
        sudo apt install -y alacritty
        print_success "alacritty installed successfully"
    fi

    # Install zellij
    if command_exists zellij; then
        print_warning "zellij is already installed, skipping..."
    else
        print_status "Installing zellij..."
        # Try apt first (available in newer Ubuntu versions)
        if sudo apt install -y zellij 2>/dev/null; then
            print_success "zellij installed via apt"
        elif command_exists cargo; then
            print_status "Installing zellij via cargo..."
            cargo install --locked zellij
            print_success "zellij installed via cargo"
        else
            print_status "Installing zellij via direct download..."
            # Download latest release binary
            ZELLIJ_VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
            wget "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz"
            tar -xzf "zellij-x86_64-unknown-linux-musl.tar.gz"
            sudo mv zellij /usr/local/bin/
            rm "zellij-x86_64-unknown-linux-musl.tar.gz"
            print_success "zellij installed via direct download"
        fi
    fi
}

# Main installation function
main() {
    print_status "Starting development tools installation..."

    local os_type=$(detect_os)

    case "$os_type" in
        "macos")
            print_status "Detected macOS"
            install_macos
            ;;
        "ubuntu")
            print_status "Detected Ubuntu/Debian-based system"
            install_ubuntu
            ;;
        *)
            print_error "Unsupported operating system: $os_type"
            print_error "This script supports macOS and Ubuntu-based Linux distributions only."
            exit 1
            ;;
    esac

    print_success "All tools installed successfully!"
    print_status "Installed tools:"
    echo "  - atuin (shell history)"
    echo "  - mise (runtime version manager)"
    echo "  - starship (shell prompt)"
    echo "  - zoxide (smart cd)"
    echo "  - bat (cat replacement)"
    echo "  - ripgrep (grep replacement)"
    echo "  - fd-find (find replacement)"
    echo "  - fzf (fuzzy finder)"
    echo "  - navi (interactive cheatsheet)"
    echo "  - eza (ls replacement)"
    echo "  - alacritty (terminal emulator)"
    echo "  - zellij (terminal workspace)"
    echo ""
    print_status "To integrate with chezmoi, place this script in your chezmoi source directory"
    print_status "and run it with: chezmoi apply --force"
}

# Run main function
main "$@"