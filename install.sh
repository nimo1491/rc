#!/bin/bash
#
# Perform installation process

declare -r SYSTEM=$(uname -s)
declare -r RC_HOME=$(pwd)
declare -r OH_MY_ZSH_DIR=~/.oh-my-zsh
declare -r TMUX_DIR=~/.tmux
declare -r FZF_DIR=~/.fzf
declare -r HOME_BIN=~/.bin
RC_FILES="zshrc p10k.zsh tigrc tmux.conf.local"

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
  RC_FILES="zshrc p10k.zsh tigrc tmux.conf.local"
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

  # Link tmux conf
  ln -s -f ${TMUX_DIR}/.tmux.conf

  # Link binary folder
  ln -s "${RC_HOME}"/bin "${HOME_BIN}"

  # Install Powerlevel10k theme
  [[ -d "${OH_MY_ZSH_DIR}"/custom/themes ]] || mkdir -p "${OH_MY_ZSH_DIR}"/custom/themes
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${OH_MY_ZSH_DIR}/custom/themes/powerlevel10k"

  # Install fzf
  ${FZF_DIR}/install --all

  # Install tmux plugins
  # ${TMUX_DIR}/plugins/tpm/bin/install_plugins

  if [[ "${SHELL}" =~ .*/zsh ]]; then
    echo "Good. You are using $SHELL. No need to chsh."
  else
    echo "Please change your shell to `which zsh`"
  fi
)
