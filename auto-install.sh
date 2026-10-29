#!/bin/bash
#
# The entry point for automatic installation.
# Main task is fetching the data from server

declare -r RC_HOME=~/.rc
declare -r OH_MY_ZSH_DIR=~/.oh-my-zsh
declare -r TMUX_DIR=~/.tmux
declare -r FZF_DIR=~/.fzf

warn() {
  echo "$1" >&2
}

die() {
  warn "$1"
  exit 1
}

[[ -e "$RC_HOME" ]] && die "~/.rc already exists."

# Get rc
git clone https://github.com/nimo1491/rc.git "${RC_HOME}" ||
  die "Failed to clone rc repository."

# Get oh-my-zsh
if ! [[ -d "${OH_MY_ZSH_DIR}" ]]; then
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "${OH_MY_ZSH_DIR}" ||
    die "Failed to clone oh-my-zsh repository."
else
  echo "oh-my-zsh has already exists, so skip downloading the new one."
fi

# Get tmux
if ! [[ -d "${TMUX_DIR}" ]]; then
  git clone --depth 1 https://github.com/gpakosz/.tmux.git "${TMUX_DIR}" ||
    die "Failed to clone tmux repository."
else
  echo "tmux has already exists, so skip downloading the new one."
fi

# Get fzf
if ! [[ -d "${FZF_DIR}" ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf "${FZF_DIR}" ||
    die "Failed to clone fzf repository."
else
  echo "fzf has already exists, so skip downloading the new one."
fi

# Perform installation
"${RC_HOME}"/install.sh || die "Failed to invoke installation process."

echo "Nimo's rc is installed."
