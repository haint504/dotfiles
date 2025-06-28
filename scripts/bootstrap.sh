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

echo "Using repository: $repo"

# Initialize chezmoi with the repo
if [ "$USE_SSH" = "true" ]; then
    "$chezmoi" init "git@github.com:$repo.git"
else
    "$chezmoi" init "https://github.com/$repo.git"
    # Switch to SSH after cloning
    chezmoi_dir="$HOME/.local/share/chezmoi"
    if [ -d "$chezmoi_dir/.git" ]; then
        cd "$chezmoi_dir"
        git remote set-url origin "git@github.com:$repo.git"
        cd - >/dev/null
    fi
fi

# Apply dotfiles
echo "Applying dotfiles..."
"$chezmoi" apply

# Explicitly run dev tools installer if it exists
dev_tools_script="$HOME/.local/share/chezmoi/install-dev-tools.sh"
if [ -f "$dev_tools_script" ]; then
    echo "Running development tools installer..."
    if [ -x "$dev_tools_script" ]; then
        "$dev_tools_script"
    else
        sh "$dev_tools_script"
    fi

    # Also trigger chezmoi's run_once mechanism
    "$chezmoi" apply
else
    echo "No dev tools installer found at $dev_tools_script"
fi