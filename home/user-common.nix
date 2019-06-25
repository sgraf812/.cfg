{ pkgs, lib, ... }:

let
  lorri-src = builtins.fetchGit { url = https://github.com/target/lorri.git; rev = "8224dfb57e508ec87d38a4ce7b9ce27bbf7c2a81"; };
  lorri = import lorri-src { src = lorri-src; };
in {
  home.packages = with pkgs; [
    # cabal2nix
    # clang
    alacritty
    audacious
    bench
    cloc
    creduce
    dtrx
    entr
    exa
    fd
    fira-code
    gcc_multi
    gitAndTools.tig
    gnumake
    htop
    haskellPackages.ghcid
    haskellPackages.lhs2tex
    (haskell.lib.overrideCabal
      (haskell.lib.doJailbreak haskellPackages.nofib-analyse)
      { broken = false; })
    lorri
    man
    manpages
    ncdu
    nix-diff
    p7zip
    python
    ripgrep
    silver-searcher
    # stack2nix
    tldr
    tmux
    tmuxinator
    tree
    unzip
    vlc
    xclip
    # zathura # doesn't build
    # ycomp
  ];

  programs.git = {
    enable = true;
    userName = "Sebastian Graf";
    aliases = {
      a = "add";
      ap = "add --patch";
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
      l = "log --decorate --graph --oneline";
      lg = "log --decorate --graph --name-status";
      publish = "!git push -u origin $(git branch-name)";
      s = "status -sb";
      sf = "svn fetch";
      suir = "submodule update --init --recursive";
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
    path = "https://github.com/rycee/home-manager/archive/release-" + lib.fileContents ./release + ".tar.gz";
  };

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile vim/vimrc.vim;
    settings = {
      relativenumber = true;
      number = true;
    };
    plugins = [
      "The_NERD_Commenter"        # Comment scripts
      "The_NERD_tree"             # File browser
      "fugitive"                  # Git commands
      "sensible"                  # Sensible defaults
      "sleuth"                    # Heuristically set buffer options
      # "Solarized" 
      "vim-airline"               # Powerline in vimscript
      "vim-dispatch"              # Asynchronous dispatcher
      "vim-gitgutter"             # Show git changes in gutter
      # "align"                     # Align stuff
      "tabular"                   # Also aligns stuff
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
      nix-zsh = "nix-shell --command zsh";
      setclip = "xclip -selection clipboard -in";
      getclip = "xclip -selection clipboard -out";
      gitc = "git checkout";
      gits = "git status -s";
      gri = "grep -ri";
      grn = "grep -rn";
      grin = "grep -rin";
      e = "vim";
      less = "\less -XFR";
      info = "info --vi-keys";
      ag = ''\ag --pager="\less -XFR"'';
      git = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin git";
      ssh = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin ssh";
      cg = "valgrind --tool=cachegrind";
      upd = "sudo apt update && sudo apt upgrade --yes && nix-channel --update && home-manager switch && . ~/.zshrc";
      ls = "exa";
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
