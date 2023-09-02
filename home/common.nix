{ config, pkgs, lib, unstable, ... }:

# Worth considering:
# - [starship](https://starship.rs): Cool cross-shell prompt
# - [sxhkd](https://github.com/baskerville/sxhkd): For X keyboard shortcuts
# - muchsync: If I ever get the E-Mail stuff working
# - xsuspend: Might be useful on the laptop
# - getmail: Automatically fetch mail in a systemd service

let
  sqlcsv = pkgs.writeShellScriptBin "sql@csv" ''
    db=$1

    if [ $# -lt 2 ] || [ ! -f $db ]; then
      echo "USAGE: $(basename $0) ./path/to/db.csv 'select avg(csv.Salary) from csv'"
      echo "       Set \$SQL_CSV_SEP if you want a separator that is different to ;"
      exit 1
    fi

    shift
    # https://til.simonwillison.net/sqlite/one-line-csv-operations
    exec -a $0 sqlite3 :memory: -cmd '.mode csv' -cmd ".separator ''${SQL_CSV_SEP:-;}" -cmd ".import $db csv" "$@"
  '';
in
{
  imports = [
    modules/ghc-dev.nix
    modules/kakoune.nix
    modules/lazygit.nix
    modules/rclone.nix
  ];

  home.packages = with pkgs; [
    audacity
    bandwhich
    bat
    bench
    # Don't install binutils here; it will interfere with Ubuntu's ld/binutils install. Set it in private.nix instead
    # binutils # ar and stuff
    bottom # alternative to top
    cabal2nix
    cabal-install
    cloc
    creduce
    dtrx
    # dust # Needs pypy (WTF)
    entr
    exa
    fd
    ghc
    (pkgs.writeShellScriptBin "ghc94" ''exec -a $0 ${haskell.compiler.ghc94}/bin/ghc "$@"'')
    (pkgs.writeShellScriptBin "ghc96" ''exec -a $0 ${haskell.compiler.ghc96}/bin/ghc "$@"'')
    glow # CLI markdown viewer
    gnumake
    # gthumb # can crop images # segfaults in ubuntu...
    haskellPackages.ghcid
    # haskellPackages.hkgr # Hackage release management, but it's broken
    haskellPackages.lhs2tex
    haskellPackages.hasktags
    unstable.haskell-language-server
    htop
    jq # Manipulating JSON on the CLI
    man
    man-pages
    moreutils
    ncdu
    # ncurses # the libtinfo uses a glibc that is often too new. That confuses GHC
    niv
    nix#Flakes
    nix-diff
    nix-index
    nix-prefetch-scripts
    nixpkgs-review
    nofib-analyse # see overlay
    p7zip
    # parallel # GNU parallel + env_parallel, clashes with moreutils
    sd
    signal-desktop
    stack
    # stack2nix # broken
    sqlcsv
    ranger
    rename # prename -- https://stackoverflow.com/a/20657563/388010
    ripgrep
    tealdeer
    tree
    xclip # Maybe use clipit instead?
    xdg_utils
    vlc
  ];

  # caches.cachix = [
  #   "ghc-nix"
  # ];

  programs.command-not-found.enable = true;

  programs.zathura.enable = true;

  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };

  # Used with nix flakes
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

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
      fixup = "commit --amend --reuse-message=HEAD"; # reuses timestamp and authorship info
      # (f)etch (o)rigin and (s)witch to new branch from origin/master
      fos = ''!bash -ec 'if (( $# != 1)); then echo >&2 git fos: 1 parameter expected; exit 2; fi; git fetch origin && git switch --create $1 --no-track origin/master' fos'';
      graph = "log --decorate --graph";
      less = "-p cat-file -p";
      l = "log --decorate --graph --oneline";
      lg = "log --decorate --graph --name-status";
      s = "status -sb";
      sf = "svn fetch";
      suir = "submodule update --init --recursive";
      tar = "archive --format=tar";
      wta = "worktree add --detach"; # "worktree add --force --detach";
      wtas = ''!bash -ec 'if (( $# != 1)); then echo >&2 git wtas: 1 parameter expected; exit 2; fi; tree=$(${pkgs.python3}/bin/python -c "from __future__ import print_function; import os, os.path, sys; print(os.path.normpath(os.path.join(os.getenv(\"PWD\"), sys.argv[1])))" "$1"); git wta "$tree"; cd "$(git rev-parse --git-dir)"; for mod in $(git config --blob HEAD:.gitmodules -l --name-only|gawk -F . "/\\.path$/ {print \$2}"); do [ -d modules/$mod ] && git -C modules/$mod wta "$tree/$(git config --blob HEAD:.gitmodules --get submodule.$mod.path)"; done' wtas'';
    };
    extraConfig = {
      core = {
        editor = "kak";
        pager = "less -x 4 -R -~"; # -F -c
        # excludesfile = "$HOME/.gitignore";
        whitespace = "trailing-space,space-before-tab";
      };
      color.ui = "auto";
      push.default = "simple";
      pull.ff = "only";
      merge.conflictstyle = "diff3";
      protocol.ext.allow = "user";
    };
  };

  programs.home-manager.enable = true;

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile vim/vimrc.vim;
    settings = {
      relativenumber = true;
      number = true;
    };
    plugins = with pkgs.vimPlugins; [
      ctrlp                # Fuzzy file finder etc.
      nerdcommenter        # Comment scripts
      nerdtree             # File browser
      fugitive             # Git commands
      sensible             # Sensible defaults
      sleuth               # Heuristically set buffer options
      # Solarized
      airline              # Powerline in vimscript
      vim-dispatch         # Asynchronous dispatcher
      gitgutter            # Show git changes in gutter
      # align              # Align stuff
      tabular              # Also aligns stuff
      tagbar               # ctags
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false; # Works around an annoying home-manager+nix interaction
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    initExtra = builtins.readFile zsh/init.zsh;
    sessionVariables = {
      # disable default rprompt...?
      RPROMPT = "";
      # hide user in shell prompt
      DEFAULT_USER = "sgraf";
      # PAGER = "kak"; # doesn't understand color codes
      EDITOR = "kak";
      hardeningDisable = "fortify";
    };
    shellAliases = {
      cdc = "cd ~/code/nix/config";
      cdnix = "cd ~/code/nix/nixpkgs && git checkout master && git pull";
      nix-zsh = "nix-shell --command zsh";
      nix-stray-roots = "nix-store --gc --print-roots | egrep -v '^(/nix/var|/run/\\w+-system|\\{memory)' | cut -d' ' -f1";
      tmux-display = "export DISPLAY=$(tmux show-env | sed -n 's/^DISPLAY=//p')";
      setclip = "xclip -selection clipboard -in";
      getclip = "xclip -selection clipboard -out";
      e = "kak";
      el = "kak -E 'colorscheme solarized-light'";
      exf = "fzf --exact"; # not FuZzy, but EXact
      less = ''\less -XFR'';
      info = "info --vi-keys";
      ls = "exa --color=automatic";
      l = "ls -l";
      ll = "l --group --header --links --extended --git";
      la = "ll -a";
      p = "(){ ${pkgs.python3}/bin/python -c \"from math import *; print($@);\" }"; # https://stackoverflow.com/questions/34340575/zsh-alias-with-parameter#comment108551041_39395740
      sshpp = ''ssh -t -Y sgraf-local@i44pc6 "zsh -l"'';
      sshfspp = "${pkgs.sshfs}/bin/sshfs sgraf-local@i44pc6:/home/sgraf-local ~/mnt/work";
      "nix-ghc-with" = ''(){ VER="$1"; shift; nix shell --impure --expr "with import <nixpkgs> {}; haskell.packages.ghc$VER.ghcWithPackages (p: with p; [ $@ ])" }'';
    };
    shellGlobalAliases = {
      # An alias for quietly forking to background:
      zzz = ">/dev/null 2>&1 &!";
    };
  };

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux/tmux.conf;
    aggressiveResize = true;
    baseIndex = 1;
    keyMode = "vi";
    shortcut = "a";
    clock24 = true;
    historyLimit = 50000;
    terminal = "screen-256color"; # colors for kakoune etc.
    secureSocket = false; # /run/user/$(id -u) is escaped in ZSH and won't work
    plugins = with pkgs; [
      tmuxPlugins.cpu
      tmuxPlugins.resurrect
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    fileWidgetCommand = "fd --type f";
    fileWidgetOptions = [ "--preview '${pkgs.bat}/bin/bat {}'" ];
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [ "--preview '${pkgs.tree}/bin/tree -C {} | head -200'" ];
    #historyWidgetOptions = [ "--sort" "--exact" ];
    tmux.enableShellIntegration = true;
  };

  services.emacs.enable = true;
  programs.doom-emacs = {
    enable = lib.mkDefault true;
    doomPrivateDir = ./doom.d;
  };

  home.keyboard.layout = "de";

  home.language = {
    base = "en_US.UTF-8";
    address = "de_DE.UTF-8";
    monetary = "de_DE.UTF-8";
    paper = "de_DE.UTF-8";
    time = "de_DE.UTF-8";
  };

  home.stateVersion = "22.11";

  services.rclone = {
    enable = lib.mkDefault true;
    mounts = {
      onedrive = { from = "OneDrive:/"; to = "${config.home.homeDirectory}/mnt/OneDrive"; };
      pcloud   = { from = "pCloud:/";   to = "${config.home.homeDirectory}/mnt/pCloud"; };
    };
  };
}
