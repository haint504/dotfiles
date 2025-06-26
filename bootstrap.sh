#!/bin/sh

set -e # -e: exit on error

echo "Setting up chezmoi"

# Check if already set up
if [ -d "$HOME/.local/share/chezmoi" ] && command -v chezmoi >/dev/null 2>&1; then
    echo "chezmoi already set up, updating instead..."
    chezmoi update
    exit 0
fi

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# Parse repo from URL or use environment variable
if [ -n "$DOTFILES_REPO" ]; then
  repo="$DOTFILES_REPO"
elif [ -n "$GITHUB_USERNAME" ]; then
  repo="$GITHUB_USERNAME/dotfiles"
else
  # Default to john if no username provided
  repo="haint504/dotfiles"
fi

# Download repo to temp directory
temp_dir=$(mktemp -d)
cd "$temp_dir"

if [ "$(command -v curl)" ]; then
  curl -fsSL "https://github.com/$repo/archive/main.tar.gz" | tar -xz --strip-components=1
elif [ "$(command -v wget)" ]; then
  wget -qO- "https://github.com/$repo/archive/main.tar.gz" | tar -xz --strip-components=1
fi

# exec: replace current process with chezmoi init
exec "$chezmoi" init --apply "--source=$temp_dir"