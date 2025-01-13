{ config, pkgs, lib, unstable, ... }:

{
  imports = [
    modules/ghc-dev.nix
    modules/kakoune.nix
    modules/lazygit.nix
    modules/rclone.nix
  ];

  home.packages = with pkgs; [
    bandwhich
    bat
    bench
    # Don't install binutils here; it will interfere with Ubuntu's ld/binutils install. Set it in private.nix instead
    # binutils # ar and stuff
    bottom # alternative to top
    cloc
    creduce
    dtrx
    # dust # Needs pypy (WTF)
    entr
    evince
    eza
    fd
    glow # CLI markdown viewer
    gnumake
    htop
    iosevka
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
    p7zip
    # parallel # GNU parallel + env_parallel, clashes with moreutils
    sd
    ranger
    rename # prename -- https://stackoverflow.com/a/20657563/388010
    ripgrep
    tealdeer
    tree
    xclip # Maybe use clipit instead?
    xdg_utils
  ];

  programs.command-not-found.enable = true;

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
      suir = "!git submodule foreach 'git checkout .' && git submodule update --init --recursive";
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
      ls = "eza --color=automatic";
      l = "ls -l";
      ll = "l --group --header --links --extended --git";
      la = "ll -a";
      p = "(){ ${pkgs.python3}/bin/python -c \"from math import *; print($@);\" }"; # https://stackoverflow.com/questions/34340575/zsh-alias-with-parameter#comment108551041_39395740
      rg-sed = ''() {
        if [ $# -lt 3 ]; then
          echo "USAGE: rg-sed regex replacement path" >&2
          return 1
        fi

        for f in $(${pkgs.ripgrep}/bin/rg --files-with-matches "$1" "$3"); do
          rg --passthrough -N "$1" -r "$2" $f | ${pkgs.moreutils}/bin/sponge $f
        done
      }'';
      sshpp = ''ssh -t -Y sgraf-local@i44pc6.ppd.ipd.kit.edu "zsh -l"'';
      sshfspp = "${pkgs.sshfs}/bin/sshfs sgraf-local@i44pc6:/home/sgraf-local ~/mnt/work";
      "nix-ghc-with" = ''(){ VER="$1"; shift; nix shell "$(nix eval --raw --apply "ghc: (ghc.ghcWithPackages (p: with p; [ $* ])).drvPath" nixpkgs#haskell.packages.ghc$VER)" }''; # https://github.com/NixOS/nix/issues/5567#issuecomment-1662884203
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
    historyWidgetOptions = [ "--sort" "--exact" ];
    tmux.enableShellIntegration = true;
  };

  services.emacs.enable = false;
  programs.doom-emacs = rec {
    enable = lib.mkDefault false; # Too much churn for how often I use it
    doomPrivateDir = ./doom.d;
    # Only init/packages so we only rebuild when those change.
    doomPackageDir = let
      filteredPath = builtins.path {
        path = doomPrivateDir;
        name = "doom-private-dir-filtered";
        filter = path: type:
          builtins.elem (baseNameOf path) [ "init.el" "packages.el" ];
      };
    in pkgs.linkFarm "doom-packages-dir" [
      {
        name = "init.el";
        path = "${filteredPath}/init.el";
      }
      {
        name = "packages.el";
        path = "${filteredPath}/packages.el";
      }
      {
        name = "config.el";
        path = pkgs.emptyFile;
      }
    ];
  };

  fonts.fontconfig.enable = true;

  home.keyboard.layout = "eu";

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
    };
  };
}
