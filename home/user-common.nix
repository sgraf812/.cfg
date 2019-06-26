{ pkgs, lib, ... }:

let
  lorri-src = builtins.fetchGit { url = https://github.com/target/lorri.git; rev = "8224dfb57e508ec87d38a4ce7b9ce27bbf7c2a81"; };
  lorri = import lorri-src { src = lorri-src; };
in {
  imports = [ 
    ./email.nix 
  ];

  home.packages = with pkgs; [
    bench
    cloc
    creduce
    dtrx
    entr
    exa
    fasd
    fd
    ghc
    gitAndTools.tig
    gnome3.geary
    gnumake
    haskellPackages.ghcid
    haskellPackages.lhs2tex
    (haskell.lib.overrideCabal
      (haskell.lib.doJailbreak haskellPackages.nofib-analyse)
      { broken = false; })
    man
    manpages
    ncdu
    nix-diff
    nix-prefetch-scripts
    p7zip
    stack
    # stack2nix
    ranger
    ripgrep
    tldr
    tmux
    tree
    xclip # Maybe use clipit instead?
    xdg_utils
    vlc
  ];

  programs.command-not-found.enable = true;

  programs.zathura.enable = true;

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
      push.default = "simple";
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
      plugins = [ "git" "fasd" ];
      theme = "robbyrussell";
    };
    initExtra = builtins.readFile zsh/init.zsh;
    sessionVariables = {
      RPROMPT = "";
    };
    shellAliases = {
      nix-zsh = "nix-shell --command zsh";
      setclip = "xclip -selection clipboard -in";
      getclip = "xclip -selection clipboard -out";
      gits = "git status -s";
      hadrid = "nix-shell --pure ../nix --run \"ghcid ./hadrian/ghci.sh\"";
      e = "vim";
      less = ''\less -XFR'';
      info = "info --vi-keys";
      ag = ''\ag --pager="\less -XFR"'';
      cg = "valgrind --tool=cachegrind";
      upd = "sudo apt update && sudo apt upgrade --yes && nix-channel --update && home-manager switch && . ~/.zshrc";
      ls = "exa";
      # We need this crazy alias so that o is bound to our function, not the
      # alias defined in the OMZ module for fasd
      o = ''\o''; 
    };
  };

  home.keyboard.layout = "de";

  home.language = {
    base = "en_US.UTF-8";
    address = "de_DE.UTF-8";
    monetary = "de_DE.UTF-8";
    paper = "de_DE.UTF-8";
    time = "de_DE.UTF-8";
  };

  home.file = {
    ".tmux.conf".source = ./tmux/tmux.conf;
    ".tmuxinator".source = ./tmuxinator;
  };

  home.stateVersion = "19.03";
}
