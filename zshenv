# Put nvm's default Node on PATH without loading nvm, so global npm tools
# (e.g. claude) work in every shell, including non-interactive ones.
() {
  local default_file=$HOME/.nvm/alias/default
  [[ -r $default_file ]] || return
  local ver=$(<$default_file)
  # Newest installed version matching the default alias (e.g. "22" -> v22.x.y)
  local -a dirs=($HOME/.nvm/versions/node/v${ver#v}*(N/On))
  (( $#dirs )) && path=($dirs[1]/bin $path)
}
