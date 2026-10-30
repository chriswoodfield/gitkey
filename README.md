# gitkey - shell alias to load correct key for github operations

This script, when called as a shell function, allows for the automatic management of multiple ssh key-based Github accounts. If you organize your repos by account, it will match the correct key (with the specified file pattern) in your $HOME/.ssh directory with the directory you're in, and use that key to authenticate with Github.

Note that this was written on a Mac, and takes advantage of the --apple-use-keychain flag, which retrieves your ssh key's passphrase from the keychain. This flag should be removed when being used on MacOS.

## Setup Instructions:

1. Set an environment variable listing your account names, space delimited.
```
export GH_ACCOUNTS="account1 account2 account3"
```

2. Create ED25519 ssh keys for each of your github accounts, named
id_ed25519_github.com_\<username\>. bash and zsh syntax differs here.

*__bash:__*
```
for account in ${GH_ACCOUNTS}; do ssh-add -t ed25519 ~/.ssh/id_ed25519_github.com_${account}; done
```
*__zsh:__*
```
for account in ${=GH_ACCOUNTS}; do ssh-add -t ed25519 ~/.ssh/id_ed25519_github.com_${account}; done
```

3. Add the public keys for these accounts to your corresponding Github accounts.

4. *(MacOS only)*: run "ssh-add \<keyname\> --apple-use-keychain" to store echo key's passphrases, eliminating the need to enter them on future add operations. (NOTE: if Linux or Windows has similar flags for keychain support, please let me know). Without this, you will be prompted 

```
for key in `ls ~/.ssh/ | grep id_ed25519_github.com | grep -v .pub`; do ssh-add ~/.ssh/${key} --apple-use-keychain; done
```

5. Create directories for each of your Github accounts. You will place your repos in the directories associated with the matching accounts.
```
for account in $(ls ~/.ssh | grep -E '^id_ed25519_github\.com_[^.]+$' | sed 's/^id_ed25519_github\.com_//'); do mkdir -p ~/git/github.com/${account}; done
```

6. Move the script to its intended location (the function below assumes ~/bin/gitkey.sh, change if needed).

7. Paste the function found in gitkey_shell_function.sh to your .rc file (.bashrc or .zshrc) to replace the default git command with gitkey when a remote command is invoked. You may also keep it as a separate file; using a source command in your .rc to load it.

8. source your shell's .rc file (.bashrc or .zshrc)

## Notes

The following env variables can be overriden:
```
GITKEY_SSH_DIR  - location of ssh keys (default: ~/.ssh)
GITKEY_BASE_DIR - parent location of github user directories (default: ~/.git/github.com)
GIT_CONFIG_FILE - location of configuration file (default: ~/.gitkey_config)
```
