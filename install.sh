#!/bin/bash
#
# Perform installation process

declare -r RC_HOME=$(pwd)
declare -r OH_MY_ZSH_DIR=~/.oh-my-zsh
declare -r TMUX_DIR=~/.tmux
declare -r FZF_DIR=~/.fzf
RC_FILES="zshrc zshenv p10k.zsh tigrc tmux.conf.local"

warn() {
  echo "$1" >&2
}

die() {
  warn "$1"
  exit 1
}

[[ -z "${RC_HOME}" ]] && die "Failed to get rc root path."

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

  # Link tmux conf
  ln -s -f ${TMUX_DIR}/.tmux.conf

  # Install Powerlevel10k theme
  if ! [[ -d "${OH_MY_ZSH_DIR}"/custom/themes/powerlevel10k ]]; then
    mkdir -p "${OH_MY_ZSH_DIR}"/custom/themes
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${OH_MY_ZSH_DIR}/custom/themes/powerlevel10k"
  fi

  # Install fzf
  ${FZF_DIR}/install --all

  command -v zoxide > /dev/null || warn "zoxide is not installed. Please install it (e.g. sudo apt install zoxide)."

  # Install tmux plugins
  # ${TMUX_DIR}/plugins/tpm/bin/install_plugins

  if [[ "${SHELL}" =~ .*/zsh ]]; then
    echo "Good. You are using $SHELL. No need to chsh."
  else
    echo "Please change your shell to `which zsh`"
  fi
)
