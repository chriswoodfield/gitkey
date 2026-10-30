## Add this function to your shell configuration file (e.g., ~/.bashrc, ~/.zshrc)
## to override the default git command with gitkey functionality

git() {
  local GITKEY_BIN="$HOME/bin/gitkey.sh"

  case "$1" in
    push|pull|fetch|clone|remote|ls-remote)
      if [[ -x "$GITKEY_BIN" ]]; then
        "$GITKEY_BIN" "$@"
      else
        command git "$@"
      fi
      ;;
    *)
      command git "$@"
      ;;
  esac
}