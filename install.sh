#!/bin/bash
#
# Perform installation process

declare -r SYSTEM=$(uname -s)
declare -r RC_HOME=$(pwd)
declare -r OH_MY_ZSH_DIR=~/.oh-my-zsh
declare -r TMUX_PLUGINS_DIR=~/.tmux/plugins
RC_FILES="zshrc tmux.conf tigrc ycm_extra_conf.py"

warn() {
  echo "$1" >&2
}

die() {
  warn "$1"
  exit 1
}

[[ -z "${RC_HOME}" ]] && die "Failed to get rc root path."
[[ -z "${SYSTEM}" ]] && die "Failed to get system information."

# Filter unnecessary files for Linux
if [[ ${SYSTEM} -ne "Darwin" ]]; then
  RC_FILES="zshrc tmux.conf tigrc ycm_extra_conf.py"
fi

(
  cd ..

  # Link all rc files
  for target in ${RC_FILES}; do
    if [[ -e ".${target}" ]] && ! [[ -L ".${target}" ]]; then
      mv ".${target}" ".${target}.old"
      echo "Backup old files."
    fi
    if ! [[ -L ".${target}" ]]; then
      ln -s "${RC_HOME}/${target}" ".${target}"
    fi
  done

  # Install Spaceship theme
  curl https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/spaceship.zsh -o ./spaceship.zsh-theme
  mv ./spaceship.zsh-theme "${OH_MY_ZSH_DIR}"/custom/themes/

  # Install tmux plugins
  ${TMUX_PLUGINS_DIR}/tpm/bin/install_plugins

  if [[ "${SHELL}" =~ .*/zsh ]]; then
    echo "Good. You are using $SHELL. No need to chsh."
  else
    echo "Please change your shell to `which zsh`"
  fi
)
