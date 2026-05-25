# FVM and BREW

## Brew

```zsh
brew outdated

brew upgrade

brew cleanup

brew doctor
```

**gnupg** — GPG signing (git commits, etc.), restart the agent so the new binary is live:
```zsh
gpgconf --kill gpg-agent
```

**ngrok** — if the cask didn't move with the others, force it:
```zsh
brew upgrade --cask ngrok
```

## FVM

### Inside VSCode project
```zsh
# inside a repo/VSCode
fvm use 3.x.x
```


### from terminal
```zsh
fvm fvm global 3.x.x
```