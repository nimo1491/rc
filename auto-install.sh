#!/bin/bash
#
# The entry point for automatic installation.
# Main task is fetching the data from server

declare -r RC_HOME=~/.rc
declare -r TMUX_PLUGINS_DIR=~/.tmux/plugins

warn() {
  echo "$1" >&2
}

die() {
  warn "$1"
  exit 1
}

[[ -e "$RC_HOME" ]] && die "~/.rc already exists."

# Get rc
git clone https://github.com/nimo1491/rc.git "${RC_HOME}"
if [[ "$?" -ne 0 ]]; then
  die "Failed to clone rc repository."
fi

# Get prezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
if [[ "$?" -ne 0 ]]; then
  die "Failed to clone prezto repository."
fi

# Get TPM for TMUX
if ! [[ -d "${TMUX_PLUGINS_DIR}" ]]; then
  mkdir -p "${TMUX_PLUGINS_DIR}"
  git clone https://github.com/tmux-plugins/tpm "${TMUX_PLUGINS_DIR}"/tpm
  if [[ "$?" -ne 0 ]]; then
    die "Failed to clone tpm repository."
  fi
else
  echo "TPM has already exists, so skip downloading the new one."
fi

# Perform installation
(
  cd ${RC_HOME}
  ./install.sh
  if [[ "$?" -ne 0 ]]; then
    die "Failed to invoking installation process."
  fi
)

echo "Nimo's rc is installed."
