{ pkgs, ... }:

{
  home.packages = [
    pkgs.arcanist
    pkgs.cabal-install
    # pkgs.cabal2nix
    # pkgs.clang
    pkgs.cloc
    # pkgs.creduce
    pkgs.entr
    pkgs.fira-code
    pkgs.gcc_multi
    pkgs.ghc
    pkgs.git
    pkgs.gmp
    pkgs.gnumake
    pkgs.htop
    # pkgs.i3
    pkgs.man
    pkgs.manpages
    pkgs.maven
    pkgs.ncdu
    pkgs.ncurses
    pkgs.nix-repl
    pkgs.nox
    pkgs.openjdk
    pkgs.openssh
    pkgs.p7zip
    pkgs.python
    pkgs.silver-searcher
    pkgs.stack
    # pkgs.stack2nix
    pkgs.tldr
    pkgs.tmux
    pkgs.tmuxinator
    pkgs.tree
    pkgs.unzip
    # pkgs.vlc # pulls in rust
    pkgs.xclip
    # pkgs.zathura # pulls in rust
    # pkgs.ycomp
  ];

  programs.git = {
    userName = "Sebastian Graf";
    aliases = {
      abort = "rebase --abort";
      amend = "commit --amend";
      cat = "cat-file -p";
      ci = "commit -a";
      co = "checkout";
      conflict = ''!"$EDITOR" -c '/^[<=|>]\\{7\\}' `git ls-files --unmerged | cut -c 51- | uniq`'';
      contains = "branch --contains";
      continue = "!git add -u && git rebase --continue";
      cx = "commit";
      da = "diff HEAD";
      di = "diff";
      dx = "diff --cached";
      fixup = "commit --amend -C HEAD";
      graph = "log --decorate --graph";
      less = "-p cat-file -p";
      lg = "log --decorate --graph --name-status";
      lg1 = "log --decorate --graph --oneline";
      sf = "svn fetch";
      tar = "archive --format=tar";
      wta = "worktree add --detach";
      wtas = ''"!bash -ec 'if (( $# != 1)); then echo >&2 git wtas: 1 parameter expected; exit 2; fi; tree=\"$(python -c \"from __future__ import print_function; import os, os.path, sys; print(os.path.normpath(os.path.join(os.getenv(\\\"PWD\\\"), sys.argv[1])))\" \"$1\")\"; git wta \"$tree\"; cd \"$(git rev-parse --git-dir)\"; for mod in $(git config --blob HEAD:.gitmodules -l --name-only|gawk -F . \"/\\.path$/ {print \\$2}\"); do [ -d modules/$mod ] && git -C modules/$mod wta \"$tree/$(git config --blob HEAD:.gitmodules --get submodule.$mod.path)\"; done' wtas"'';
    };
    extraConfig = {
      core = { 
        editor = "vim";
        pager = "less -x 4 -R -~"; # -F -c
        # excludesfile = "$HOME/.gitignore";
        whitespace = "trailing-space,space-before-tab";
      };
      color.ui = "auto";
      push.default = "matching";
        "url \"git://github.com/ghc/packages-\"".insteadOf = "git://github.com/ghc/packages/";
        "url \"http://github.com/ghc/packages-\"".insteadOf = "http://github.com/ghc/packages/";
        "url \"https://github.com/ghc/packages-\"".insteadOf = "https://github.com/ghc/packages/";
        "url \"ssh://git@github.com/ghc/packages-\"".insteadOf = "ssh://git@github.com/ghc/packages/";
        "url \"git@github.com/ghc/packages-\"".insteadOf = "git@github.com/ghc/packages/";
    };
  };

  programs.home-manager = {
    enable = true;
    path = https://github.com/rycee/home-manager/archive/master.tar.gz;
  };

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile vim/vimrc.vim;
    settings = {
      relativenumber = true;
      number = true;
    };
    plugins = [
      "The_NERD_Commenter"  # Comment scripts
      "The_NERD_tree"       # File browser
      "fugitive"            # Git commands
      "sensible"            # Sensible defaults
      "sleuth"              # Heuristically set buffer options
      # "Solarized" 
      "vim-airline"         # Powerline in vimscript
      "vim-gitgutter"       # Show git changes in gutter
    ];
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    initExtra = builtins.readFile zsh/init.zsh;
    shellAliases = {
      setclip = "xclip -selection clipboard -in";
      getclip = "xclip -selection clipboard -out";
      gitc = "git checkout";
      gits = "git status";
      gri = "grep -ri";
      grn = "grep -rn";
      grin = "grep -rin";
      e = "vim";
      less = "\less -XFR";
      info = "info --vi-keys";
      ag = ''\ag --pager="\less -XFR"'';
      git = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin git";
      ssh = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin ssh";
    };
  };

  home.file = {
    ".tmux.conf".source = ./tmux/tmux.conf;
    ".tmuxinator".source = ./tmuxinator;
  };

#  xsession.windowManager.i3 = {
#    enable = true;
#    config = {
#      assigns = {
#        "1: web" = [{ class = "^Firefox$"; }];
#        "10: spotify" = [{ class = "^Spotify$"; }];
#      };
#
#      fonts = [ "monospace 10" ];
#    };
#  };
}
