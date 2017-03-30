#!/bin/bash
#
# Uninstall all files except .rc

# prezto
rm -rf .zcompdump
rm -rf .zcompdump.zwc
rm -rf .zlogin
rm -rf .zlogout
rm -rf .zprezto/
rm -rf .zpreztorc
rm -rf .zprofile
rm -rf .zshenv
rm -rf .zshrc

# tmux
rm -rf .tmux/
rm -rf .tmux.conf

# tig
rm -rf .tigrc

# YCM
rm -rf .ycm_extra_conf.py
