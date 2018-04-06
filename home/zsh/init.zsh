# Deactivate tty flow control (e.g. suspending with ctlr-s and resuming with ctrl-q)
stty -ixon

export EDITOR=e
export SPEC_PATH=/data1/graf/spec/cpu2017/
export SHELL=$(which zsh)
export PATH=$HOME/.stack/bin:$HOME/.cabal/bin:/data1/graf/bin:$PATH
export MANPATH=/nix/var/nix/profiles/default/share/man:$HOME/.nix-profile/share/man:$MANPATH

bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1~' beginning-of-line
bindkey '^E' end-of-line


dm () {
  PROG=$(which $1)
  shift
  nohup $PROG $@ > /dev/null 2>&1 &
  disown
}

# Rebuild config and launch tmux if not already in some mux session,
# before setting any aliases
if command -v tmux>/dev/null && [[ ! $TERM =~ screen && -z $TMUX ]]; then
  home-manager switch
  tmux new-session -s root -n main -c $(pwd)
  exec tmux attach -t root
fi

