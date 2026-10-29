# Nimo's rc Files

My configuration files for zsh, tmux and tig, tested on Ubuntu.

| Tool | Config | Notes |
| --- | --- | --- |
| zsh | `zshrc`, `zshenv` | oh-my-zsh, fzf helpers, zoxide |
| Prompt | `starship.toml` | starship by default, Powerlevel10k (`p10k.zsh`) as fallback |
| Versions | `mise.toml` | Node 22, Neovim, starship, delta, ripgrep, bat, zoxide and global CLI tools via mise (pinned); Python stays on the system version |
| tmux | `tmux.conf.local` | on top of [oh-my-tmux](https://github.com/gpakosz/.tmux) |
| tig | `tigrc` | vim movement, OSC 52 copy, delta view |

## Requirements

Install these first (Ubuntu):

    sudo apt install git curl zsh tmux tig tree pipx

Neovim, starship, delta, ripgrep, bat and zoxide are installed by mise at the
versions pinned in `mise.toml`. It is still worth installing the apt packages
`neovim ripgrep bat git-delta zoxide` as fallbacks for contexts without mise
(sudo, other users, tools that run git without your shell). `pipx` is needed by
mise to install the `pipx:` tools.

## Install

    curl -fsSL https://raw.githubusercontent.com/nimo1491/rc/master/auto-install.sh | bash

This clones the repo to `~/.rc` together with oh-my-zsh, oh-my-tmux and fzf, then
runs `install.sh`, which:

- links the rc files into `~` (existing files are backed up as `*.old`)
- links `starship.toml` and `mise.toml` into `~/.config`
- installs mise into `~/.local/bin` and runs `mise install`
- warns about any missing commands

To re-run the setup on an existing clone, run `~/.rc/install.sh`.

### After installing

- Set the commit identity for this repo:

      git -C ~/.rc config user.name "Nimo Hsieh"
      git -C ~/.rc config user.email "nimo1491@gmail.com"

- Start a new shell with `exec zsh`, or `chsh -s $(which zsh)` if zsh is not
  the login shell yet.

## Usage

### zsh

| Command | Description |
| --- | --- |
| `z <keyword>` | jump to a frequently used directory (zoxide) |
| `z` / `zi` | pick a directory with fzf |
| `v [query]` | open a recently edited file in nvim |
| `Rg <pattern>` | ripgrep, then pick a match with fzf and open it |
| `RG [pattern]` | live ripgrep with fzf |
| `fco` | check out a git branch or tag with fzf |
| `fshow` | browse git commits with fzf |
| `fs` | switch tmux sessions |
| `venv <name>` | activate a virtualenv in `~/.venvs/<name>` |
| `tiga` | `tig --all` |

To use Powerlevel10k instead of starship for a shell, start it with
`RC_PROMPT=p10k zsh`.

### mise

The global config only sets Node and CLI tools, so `python3` stays the system
interpreter. Pick other versions per project or per command:

    mise use python@3.13                    # in a project directory
    mise exec python@3.13 -- python app.py  # one-off

### tig

On top of the default key bindings:

| Key | Description |
| --- | --- |
| `g` / `G` | go to the first / last line (use `:grep` for the grep view) |
| `Ctrl-f` / `Ctrl-b` | page down / up |
| `y` | copy the commit ID to the local clipboard (OSC 52) |
| `V` | show the commit with delta (main view) |
| `T` | toggle the revision graph (main view) |
| `D` | cycle the date format |
