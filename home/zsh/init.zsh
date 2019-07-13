# Source the home-manager profile
. ~/.nix-profile/etc/profile.d/hm-session-vars.sh

# Deactivate tty flow control (e.g. suspending with ctlr-s and resuming with ctrl-q)
stty -ixon

# https://github.com/NixOS/nixpkgs/issues/30121
setopt prompt_sp

export EDITOR=vim
export SPEC_PATH=/data1/graf/spec/cpu2017/
export SHELL=$(which zsh)
export PATH=$HOME/.stack/bin:$HOME/.cabal/bin:/data1/graf/bin:$PATH
#export PATH=$HOME/.stack/bin:$HOME/.cabal/bin:/data1/graf/bin:/opt/ghc/bin:/opt/cabal/bin:$PATH
export MANPATH=/nix/var/nix/profiles/default/share/man:$HOME/.nix-profile/share/man:$MANPATH
export hardeningDisable=fortify # because WTF, Nixpkgs?!!

bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# Make Ctrl+arrow, Pos1, End, Del, Ins work

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="$terminfo[khome]"
key[End]="$terminfo[kend]"
key[Insert]="$terminfo[kich1]"
key[Backspace]="$terminfo[kbs]"
key[Delete]="$terminfo[kdch1]"
key[Up]="$terminfo[kcuu1]"
key[Down]="$terminfo[kcud1]"
key[Left]="$terminfo[kcub1]"
key[Right]="$terminfo[kcuf1]"
key[PageUp]="$terminfo[kpp]"
key[PageDown]="$terminfo[knp]"

# setup key accordingly
[[ -n "$key[Home]"      ]] && bindkey -- "$key[Home]"      beginning-of-line
[[ -n "$key[End]"       ]] && bindkey -- "$key[End]"       end-of-line
[[ -n "$key[Insert]"    ]] && bindkey -- "$key[Insert]"    overwrite-mode
[[ -n "$key[Backspace]" ]] && bindkey -- "$key[Backspace]" backward-delete-char
[[ -n "$key[Delete]"    ]] && bindkey -- "$key[Delete]"    delete-char
[[ -n "$key[Up]"        ]] && bindkey -- "$key[Up]"        up-line-or-history
[[ -n "$key[Down]"      ]] && bindkey -- "$key[Down]"      down-line-or-history
[[ -n "$key[Left]"      ]] && bindkey -- "$key[Left]"      backward-char
[[ -n "$key[Right]"     ]] && bindkey -- "$key[Right]"     forward-char

# These still aren't bound and not present in $terminfo
bindkey "^[[1;5D" backward-word # Ctrl-Left
bindkey "^[[1;5C" forward-word  # Ctrl-Right

# Finally, make sure the terminal is in application mode when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init () {
    echoti smkx
  }
  function zle-line-finish () {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

function test_exec() {
  command -v $1 > /dev/null
}

# Rebuild config and launch tmux if not already in some mux session,
# before setting any aliases
if [ "x$USE_TMUX" = "xyes" ] && command -v tmux>/dev/null && [[ ! $TERM =~ screen && -z $TMUX ]]; then
  home-manager switch
  tmux new-session -s root -n main -c $(pwd)
  exec tmux attach -t root
fi

# An alias for quietly forking to background:
alias -g zzz='>/dev/null 2>&1 &!'
# We need -g (and thus use it here), otherwise it won't expand in postfix position

# Making and changing into a directory:
function mkcd() {
  mkdir -p $@;
  cd $@;
}

# An alias for a quiet xdg-open
function o() {
  xdg-open $@ zzz
}

# Opens the first result of fd
function efd() {
  e $(fd $1)
}

# Returns the nix store path of the given executable by stripping of the bin/blah suffix
function nix-which() {
  echo "$(dirname $(dirname $(readlink -f $(which $1))))"
}

function efd() {
  vim $(fd $1)
}

function cpfd() {
  cp $(fd $1) $2
}

function ncpus() {
  grep -c ^processor /proc/cpuinfo
}

# Run a cached, local hadrian build from a nix-shell
function hadr() {
  args=("hadrian/build.sh" "-j$(($(ncpus) + 1))" "$@")
  echo "${args[*]}"
  nix-shell --pure ../nix --run "TEST=\"$TEST\" ${args[*]}"
}
