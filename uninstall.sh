#!/bin/bash
#
# Uninstall all files except .rc

# prezto
[[ -e .zcompdump ]] && rm -rf .zcompdump
[[ -e .zcompdump.zwc ]] && rm -rf .zcompdump.zwc
[[ -e .zlogin ]] && rm -rf .zlogin
[[ -e .zlogout ]] && rm -rf .zlogout
[[ -d .zprezto ]] && rm -rf .zprezto/
[[ -e .zpreztorc ]] && rm -rf .zpreztorc
[[ -e .zprofile ]] && rm -rf .zprofile
[[ -e .zshenv ]] && rm -rf .zshenv
[[ -e .zshrc ]] && rm -rf .zshrc

# tmux
[[ -d .tmux/ ]] && rm -rf .tmux/
[[ -e .tmux.conf ]] && rm -rf .tmux.conf

# tig
[[ -e .tigrc ]] && rm -rf .tigrc

# YCM
[[ -e .ycm_extra_conf.py ]] && rm -rf .ycm_extra_conf.py
