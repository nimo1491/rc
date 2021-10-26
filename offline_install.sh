#!/usr/bin/env bash

declare -r BIN=.bin
declare -r OH_MY_ZSH=.oh-my-zsh
declare -r FZF=.fzf
declare -r TMUX=.tmux
RC_FILES="zshrc p10k.zsh tigrc tmux.conf.local"

cd "$(dirname "${BASH_SOURCE[0]}")"
rc_base="$(pwd)"

if [[ "$1" == "pull" ]]; then
    cp -r "$HOME"/"$OH_MY_ZSH" "$rc_base"
    cp -r "$HOME"/"$TMUX" "$rc_base"
    cp -r "$HOME"/"$FZF" "$rc_base"
    exit 0
fi

# Link all rc files
for target in ${RC_FILES}; do
if ! [[ -L "$HOME"/.${target} ]]; then
  ln -s "$rc_base"/${target} "$HOME"/.${target}
fi
done

# Link oh-my-zsh folder
if ! [[ -L "$HOME"/"$OH_MY_ZSH" ]]; then
  ln -s "$rc_base"/"$OH_MY_ZSH" "$HOME"/"$OH_MY_ZSH"
fi

# Link tmux folder
if ! [[ -L "$HOME"/"$TMUX" ]]; then
  ln -s "$rc_base"/"$TMUX" "$HOME"/"$TMUX"
fi

# Link fzf folder
if ! [[ -L "$HOME"/"$FZF" ]]; then
    ln -s "$rc_base"/"$FZF" "$HOME"/"$FZF"
fi

# Install fzf
"$HOME"/"$FZF"/install --all

if [[ "${SHELL}" =~ .*/zsh ]]; then
echo "Good. You are using $SHELL. No need to chsh."
else
echo "Please change your shell to `which zsh`"
fi
