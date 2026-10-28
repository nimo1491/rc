export PATH=$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:$PATH

# Prompt: starship by default; start zsh with RC_PROMPT=p10k (or without
# starship installed) to fall back to Powerlevel10k
if [[ $RC_PROMPT != p10k ]] && (( $+commands[starship] )); then
  RC_PROMPT=starship
else
  RC_PROMPT=p10k
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ $RC_PROMPT == p10k && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
[[ $RC_PROMPT == starship ]] && ZSH_THEME="" || ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git vi-mode history-substring-search colored-man-pages npm node python docker)

source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

alias vi='nvim'           # vim
alias tiga='tig --all'   # tig all branches

# fzf
fzf-down() {
  fzf --height 65% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

# ripgrep
Rg() {
  local selected=$(
    rg --column --line-number --no-heading --color=always --smart-case "$1" |
      fzf --ansi \
          --delimiter : \
          --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
          --preview-window '~3:+{2}+3/2' |
      awk -F ':' '{print $1}'
  )
  [ -n "$selected" ] && $EDITOR "$selected"
}

RG() {
  local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  local INITIAL_QUERY="$1"
  local selected=$(
    FZF_DEFAULT_COMMAND="$RG_PREFIX ${(qq)INITIAL_QUERY} || true" \
      fzf --bind "change:reload:$RG_PREFIX {q} || true" \
          --ansi --disabled --query "$INITIAL_QUERY" \
          --delimiter : \
          --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
          --preview-window '~3:+{2}+3/2' |
      awk -F ':' '{print $1}'
  )
  [ -n "$selected" ] && $EDITOR "$selected"
}

# v - open a recently edited file (from nvim's oldfiles)
v() {
  local file
  file="$(
    nvim -u NONE --headless -c 'lua io.stdout:write(table.concat(vim.v.oldfiles, "\n"))' -c 'qa!' 2> /dev/null |
      while read -r f; do [[ -f $f ]] && print -r -- "$f"; done |
      fzf-tmux -1 -0 --no-sort +m --query="$1"
  )" && vi "${file}" || return 1
}

# Advanced customization of fzf options
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} 2> /dev/null || ls -A --color=always {}' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" ;;
  esac
}

# Switch tmux-sessions
fs() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" | \
        fzf --height 40% --reverse --query="$1" --select-1 --exit-0) &&
    tmux switch-client -t "$session"
}

# GIT heart FZF
# -------------

# fco - checkout git branch/tag
fco() {
  local tags branches target
  tags=$(git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") |
    fzf-tmux -l30 -- --no-hscroll --ansi +m -d "\t" -n 2) || return
  git checkout $(echo "$target" | awk '{print $2}')
}

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
    --format="%Cred%h %Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 |
            xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            {}
            FZF-EOF"
}

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

_gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

_gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

_gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

# Not named _gh, which is the completion function of GitHub CLI
_fgh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

_gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

_gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
}

[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# mise - Node / Python versions (global defaults in ~/.config/mise/config.toml)
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# venv - activate a shared virtualenv under ~/.venvs, e.g. `venv robot`
venv() {
  [[ -f ~/.venvs/$1/bin/activate ]] || { echo "venv: no such virtualenv: $1" >&2; return 1 }
  source ~/.venvs/$1/bin/activate
}
compdef "_path_files -W $HOME/.venvs -/" venv

if [[ $RC_PROMPT == starship ]]; then
  ZLE_RPROMPT_INDENT=0
  eval "$(starship init zsh)"
else
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

# zoxide (z / zi); must be initialized after compinit
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
  # Plain `z` opens the interactive picker (like `zi`) instead of going home
  _rc_z() {
    if (( $# )); then
      __zoxide_z "$@"
    else
      __zoxide_zi
    fi
  }
  alias z=_rc_z
  (( $+functions[__zoxide_z_complete] )) && compdef __zoxide_z_complete _rc_z
fi
