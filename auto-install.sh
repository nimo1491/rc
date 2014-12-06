#!/bin/bash
RC_HOME=~/.rc

warn() {
    echo "$1" >&2
}

die() {
    warn "$1"
    exit 1
}

[ -e $RC_HOME ] && die "~/.rc already exists."

git clone https://github.com/nimo1491/rc.git "$RC_HOME"
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
cd "$RC_HOME"

./install.sh

echo "nimo's rc is installed."
