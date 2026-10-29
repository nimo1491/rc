# Nimo's rc Files

My configuration files for zsh, Neovim, tmux and tig, tested on Ubuntu.

| Tool | Config | Notes |
| --- | --- | --- |
| zsh | `zsh/` | oh-my-zsh, fzf helpers, zoxide |
| Prompt | `starship/` | starship; falls back to oh-my-zsh's robbyrussell theme if starship is missing |
| Versions | `mise/` | Node 22, Neovim, starship, delta, ripgrep, bat, zoxide and global CLI tools via mise (pinned); Python stays on the system version |
| Neovim | `nvim/` | vim-plug, coc.nvim, fzf, airline; merged from the old nimo1491/vimrc |
| tmux | `tmux/` | on top of [oh-my-tmux](https://github.com/gpakosz/.tmux) |
| tig | `tig/` | vim movement, OSC 52 copy, delta view |

## Requirements

Install these first (Ubuntu):

    sudo apt install git curl zsh tmux tig tree pipx universal-ctags

Neovim, starship, delta, ripgrep, bat, zoxide and clangd are installed by mise at the
versions pinned in `mise/config.toml`. It is still worth installing the apt packages
`neovim ripgrep bat git-delta zoxide` as fallbacks for contexts without mise
(sudo, other users, tools that run git without your shell). `pipx` is needed by
mise to install the `pipx:` tools.

## Install

    curl -fsSL https://raw.githubusercontent.com/nimo1491/rc/master/auto-install.sh | bash

This clones the repo to `~/.rc` together with oh-my-zsh, oh-my-tmux and fzf, then
runs `install.sh`, which:

- links the config files into `~` and `~/.config` as listed in `LINKS`
  (existing files are backed up as `*.old`)
- installs mise into `~/.local/bin` and runs `mise install`
- installs the Neovim plugins
- warns about any missing commands

To re-run the setup on an existing clone, run `~/.rc/install.sh`.

### After installing

- Set the commit identity for this repo:

      git -C ~/.rc config user.name "Nimo Hsieh"
      git -C ~/.rc config user.email "nimo1491@gmail.com"

- coc.nvim installs its extensions on the first start. clangd for C/C++
  completion comes from mise; Tagbar uses universal-ctags from apt.
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

### Neovim

The leader key is `,`.

| Key | Description |
| --- | --- |
| `,p` | find files (fzf) |
| `,<Enter>` | switch buffers |
| `,ag` / `,Ag` | live ripgrep / ripgrep for the word under the cursor |
| `,f` | search the word under the cursor with CtrlSF |
| `,h` | recently opened files |
| `,e` / `,,e` | toggle NERDTree / reveal the current file |
| `,t` | toggle Tagbar |
| `,gd` / `,gi` / `,su` | go to definition / implementation / references (coc) |
| `K` | show documentation |
| `s` | EasyMotion jump |
| `Ctrl-n` | multiple cursors (vim-visual-multi) |
| `,G` | Goyo distraction-free mode |
| `,/` | clear search highlighting |
| `:cd.` | change the window's directory to the current file's |
| `:w!!` | save with sudo |

Run `:PlugUpdate` to update the plugins and `:CocUpdate` for the coc extensions.

The Neovim config started from ideas in
[mosky.vim](https://github.com/moskytw/mosky.vim),
[junegunn/dotfiles](https://github.com/junegunn/dotfiles),
[ycavatars/vimrc](https://github.com/ycavatars/vimrc),
[othree/rc](https://github.com/othree/rc),
[vgod/vimrc](https://github.com/vgod/vimrc) and
[janus](https://github.com/carlhuda/janus).
