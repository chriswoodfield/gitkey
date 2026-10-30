# gitkey - shell alias to load correct key for github operations

This script, when called as a shell function, allows for the automatic management of multiple ssh key-based Github accounts. If you organize your repos by account, it will match the correct key (with the specified file pattern) in your $HOME/.ssh directory with the directory you're in, and use that key to authenticate with Github.

Note that this was written on a Mac, and takes advantage of the --apple-use-keychain flag, which retrieves your ssh key's passphrase from the keychain. This flag should be removed when being used on MacOS.

## Setup Instructions:

1. Create ED25519 ssh keys for each of your github accounts, named
id_ed25519_github.com_\<username\>

2. On MacOS, you can run "ssh-add \<keyname\> --apple-use-keychain" to store the key's passphrases, eliminating the need to enter them on future load operations.

3. Create directories for each of these accounts. 
~/git/github.com/\<username\>

4. Move the script to its intended location (the function below assumes ~/bin/gitkey.sh, change if needed).

5. Add the following function to your .bashrc or .zshrc file. This will catch remote git functions, while allowing other operations to proeed normally.
```
# Wrapper for git to route remote operations through gitkey

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
```

4. Reload your .rc file (.bashrc or .zshrc)

The following env variables can be overriden:
```
GITKEY_SSH_DIR  - location of ssh keys (default: ~/.ssh)
GITKEY_BASE_DIR - parent location of github user directories (default: ~/.git/github.com)
GIT_CONFIG_FILE - location of configuration file (default: ~/.gitkey_config)
```
