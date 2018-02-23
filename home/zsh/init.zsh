# Deactivate tty flow control (e.g. suspending with ctlr-s and resuming with ctrl-q)
stty -ixon

export EDITOR=e
export SPEC_PATH=/data1/graf/spec/cpu2017/
export SHELL=$(which zsh)
export PATH=/data1/graf/stack/bin:/data1/graf/cabal/bin:/data1/graf/bin:$PATH
export MANPATH=/nix/var/nix/profiles/default/share/man:$HOME/.nix-profile/share/man:$MANPATH

bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# Rebuild config and launch tmux if not already in some mux session,
# before setting any aliases
if command -v tmux>/dev/null && [[ ! $TERM =~ screen && -z $TMUX ]]; then
  home-manager switch
  tmux new-session -s root -n main -c $(pwd)
  exec tmux attach -t root
fi

