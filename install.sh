#!/bin/bash
#
# Perform installation process

declare -r RC_HOME=$(pwd)
declare -r OH_MY_ZSH_DIR=~/.oh-my-zsh
declare -r TMUX_DIR=~/.tmux
declare -r FZF_DIR=~/.fzf
declare -r LOCAL_BIN=~/.local/bin
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

  # Link starship config
  mkdir -p .config
  [[ -L .config/starship.toml ]] || ln -s "${RC_HOME}"/starship.toml .config/starship.toml

  # Link mise global config
  mkdir -p .config/mise
  [[ -L .config/mise/config.toml ]] || ln -s "${RC_HOME}"/mise.toml .config/mise/config.toml

  # Install Powerlevel10k theme
  if ! [[ -d "${OH_MY_ZSH_DIR}"/custom/themes/powerlevel10k ]]; then
    mkdir -p "${OH_MY_ZSH_DIR}"/custom/themes
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${OH_MY_ZSH_DIR}/custom/themes/powerlevel10k"
  fi

  # Install fzf
  ${FZF_DIR}/install --all

  command -v zoxide > /dev/null || warn "zoxide is not installed. Please install it (e.g. sudo apt install zoxide)."

  # Install starship and mise into ~/.local/bin (no sudo needed)
  mkdir -p "${LOCAL_BIN}"
  if ! command -v starship > /dev/null && ! [[ -x "${LOCAL_BIN}"/starship ]]; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "${LOCAL_BIN}" ||
      warn "Failed to install starship, falling back to Powerlevel10k."
  fi
  if ! command -v mise > /dev/null && ! [[ -x "${LOCAL_BIN}"/mise ]]; then
    curl -sS https://mise.run | MISE_INSTALL_PATH="${LOCAL_BIN}"/mise sh ||
      warn "Failed to install mise."
  fi

  # Install the tools listed in mise.toml
  if [[ -x "${LOCAL_BIN}"/mise ]]; then
    "${LOCAL_BIN}"/mise install || warn "Failed to run mise install."
  elif command -v mise > /dev/null; then
    mise install || warn "Failed to run mise install."
  fi

  # Install tmux plugins
  # ${TMUX_DIR}/plugins/tpm/bin/install_plugins

  if [[ "${SHELL}" =~ .*/zsh ]]; then
    echo "Good. You are using $SHELL. No need to chsh."
  else
    echo "Please change your shell to `which zsh`"
  fi
)
