#!/bin/bash
#
# Perform installation process

declare -r RC_HOME=$(cd "$(dirname "$0")" && pwd)
declare -r TMUX_DIR=~/.tmux
declare -r FZF_DIR=~/.fzf
declare -r LOCAL_BIN=~/.local/bin
# Config files to link, as "<path in this repo>:<path under ~>"
LINKS=(
  "zsh/zshrc:.zshrc"
  "zsh/zshenv:.zshenv"
  "tmux/tmux.conf.local:.tmux.conf.local"
  "tig/tigrc:.tigrc"
  "starship/starship.toml:.config/starship.toml"
  "mise/config.toml:.config/mise/config.toml"
  "nvim/init.vim:.config/nvim/init.vim"
  "nvim/coc-settings.json:.config/nvim/coc-settings.json"
)
# Commands the configs rely on (rg, bat, delta, zoxide, starship and nvim come
# from mise/config.toml; the rest from apt)
REQUIRED_CMDS="zsh tmux tig nvim rg bat delta zoxide starship tree pipx"

warn() {
  echo "$1" >&2
}

die() {
  warn "$1"
  exit 1
}

# Link ~/<dst> to <src> in this repo, backing up an existing regular file.
# An existing link is replaced, so moved files in the repo are picked up.
link() {
  local src="${RC_HOME}/$1" dst="$2" backup

  mkdir -p "$(dirname "${dst}")"
  if [[ -e "${dst}" ]] && ! [[ -L "${dst}" ]]; then
    backup="${dst}.old"
    [[ -e "${backup}" ]] && backup="${backup}.$(date +%Y%m%d%H%M%S)"
    mv "${dst}" "${backup}"
    echo "Backup ~/${dst} to ~/${backup}."
  fi
  ln -sfn "${src}" "${dst}"
}

[[ -z "${RC_HOME}" ]] && die "Failed to get rc root path."

(
  cd ~ || die "Failed to change to the home directory."

  # Link all config files
  for entry in "${LINKS[@]}"; do
    link "${entry%%:*}" "${entry#*:}"
  done
  ln -sfn ${TMUX_DIR}/.tmux.conf .tmux.conf

  # Remove links left over from older layouts of this repo
  [[ -L .p10k.zsh ]] && ! [[ -e .p10k.zsh ]] && rm .p10k.zsh
  # Older setups linked this directory to ~/.vim/autoload
  [[ -L .local/share/nvim/site/autoload ]] && rm .local/share/nvim/site/autoload

  # Install fzf
  ${FZF_DIR}/install --all

  # Install mise into ~/.local/bin (no sudo needed)
  mkdir -p "${LOCAL_BIN}"
  if ! command -v mise > /dev/null && ! [[ -x "${LOCAL_BIN}"/mise ]]; then
    curl -sS https://mise.run | MISE_INSTALL_PATH="${LOCAL_BIN}"/mise sh ||
      warn "Failed to install mise."
  fi

  # Install the tools listed in mise/config.toml (pipx:* tools need pipx)
  if [[ -x "${LOCAL_BIN}"/mise ]]; then
    "${LOCAL_BIN}"/mise install || warn "Failed to run mise install."
  elif command -v mise > /dev/null; then
    mise install || warn "Failed to run mise install."
  fi

  # Install the Neovim plugins with vim-plug
  if ! [[ -f .local/share/nvim/site/autoload/plug.vim ]]; then
    curl -fsSLo .local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ||
      warn "Failed to download vim-plug."
  fi
  PATH="${HOME}/.local/share/mise/shims:${PATH}" nvim --headless +'PlugInstall --sync' +qall ||
    warn "Failed to install Neovim plugins."

  missing=""
  for cmd in ${REQUIRED_CMDS}; do
    PATH="${HOME}/.local/share/mise/shims:${PATH}" command -v "${cmd}" > /dev/null ||
      missing="${missing} ${cmd}"
  done
  [[ -n "${missing}" ]] && warn "Missing commands:${missing}. See README.md for the packages to install."

  # Install tmux plugins
  # ${TMUX_DIR}/plugins/tpm/bin/install_plugins

  if [[ "${SHELL}" =~ .*/zsh ]]; then
    echo "Good. You are using $SHELL. No need to chsh."
  else
    echo "Please change your shell to `which zsh`"
  fi
)
