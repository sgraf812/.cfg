{ pkgs, lib, ... }:

# Worth considering:
# - [starship](https://starship.rs): Cool cross-shell prompt
# - [sxhkd](https://github.com/baskerville/sxhkd): For X keyboard shortcuts
# - muchsync: If I ever get the E-Mail stuff working
# - xsuspend: Might be useful on the laptop
# - getmail: Automatically fetch mail in a systemd service

{
  imports = [ 
    modules/ghc-dev.nix
    modules/cachix.nix
  ];

  home.packages = with pkgs; [
    audacity
    bandwhich
    bat
    bench
    binutils # ar and stuff
    cabal2nix
    cabal-install
    cloc
    creduce
    dtrx
    # dust # Needs pypy (WTF)
    entr
    exa
    fd
    fzf
    ghc
    gitAndTools.tig
    gnumake
    # gthumb # can crop images # segfaults in ubuntu...
    haskellPackages.ghcid
    # haskellPackages.hkgr # Hackage release management, but it's broken
    haskellPackages.lhs2tex
    haskellPackages.hasktags
    unstable.haskell-language-server
    man
    manpages
    ncdu
    ncurses
    niv
    nix-diff
    nix-index
    nix-prefetch-scripts
    nofib-analyse # see overlay
    p7zip
    sd
    stack
    # stack2nix # broken
    ranger
    rename # prename -- https://stackoverflow.com/a/20657563/388010
    ripgrep
    tealdeer
    tree
    xclip # Maybe use clipit instead?
    xdg_utils
    vlc
    ytop

    # Haskell/Cabal/Stack stuff
    # haskell-ci # old version, can't get it to work on unstable either
    zlib.dev
    gmp.static
    numactl
  ];

  caches.cachix = [
    "ghc-nix"
  ];

  programs.command-not-found.enable = true;

  programs.zathura.enable = true;

  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };

  # Used with lorri
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
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
      wtas = ''!bash -ec 'if (( $# != 1)); then echo >&2 git wtas: 1 parameter expected; exit 2; fi; tree=\"$(python -c \"from __future__ import print_function; import os, os.path, sys; print(os.path.normpath(os.path.join(os.getenv(\\\"PWD\\\"), sys.argv[1])))\" \"$1\")\"; git wta \"$tree\"; cd \"$(git rev-parse --git-dir)\"; for mod in $(git config --blob HEAD:.gitmodules -l --name-only|gawk -F . \"/\\.path$/ {print \\$2}\"); do [ -d modules/$mod ] && git -C modules/$mod wta \"$tree/$(git config --blob HEAD:.gitmodules --get submodule.$mod.path)\"; done' wtas'';
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
      pull.ff = "only";
      merge.conflictstyle = "diff3";
    };
  };

  programs.home-manager.enable = true;

  programs.kakoune = {
    enable = true;
    config = {
      numberLines = {
        enable = true;
        relative = true;
      };
      scrollOff = {
        columns = 5;
        lines = 2;
      };
      showMatching = true;
    };
    plugins = with pkgs.kakounePlugins; [
      kak-fzf
      kak-powerline
      # kak-vertical-selection # unclear if needed
      kak-lsp
    ];
    extraConfig = ''
      colorscheme tomorrow-night
      hook global InsertChar k %{ try %{
            exec -draft hH <a-k>jk<ret> d
              exec <esc>
      }}
      map global normal <c-p> ': fzf-mode<ret>'
      map global normal 0 <a-h>
      map global normal $ <a-l>
      map global normal § $

      # User mode stuff
      ## Copy and pasting from clipboard
      map global user y '<a-|>${pkgs.xclip}/bin/xclip -selection clipboard -in <ret>'
      map global user p '<a-!>${pkgs.xclip}/bin/xclip -selection clipboard -out <ret>'
      map global user P '!${pkgs.xclip}/bin/xclip -selection clipboard -out <ret>'
      ## Other shortcuts
      map global user w ':write <ret>' -docstring "Save current buffer"
      map global user e ':e<space>'

      # Tab completion
      hook global InsertCompletionShow .* %{
          try %{
              # this command temporarily removes cursors preceded by whitespace;
              # if there are no cursors left, it raises an error, does not
              # continue to execute the mapping commands, and the error is eaten
              # by the `try` command so no warning appears.
              execute-keys -draft 'h<a-K>\h<ret>'
              map window insert <tab> <c-n>
              map window insert <s-tab> <c-p>
          }
      }
      hook global InsertCompletionHide .* %{
          unmap window insert <tab> <c-n>
          unmap window insert <s-tab> <c-p>
      }
    '';
  };

  xdg.configFile."kak-lsp/kak-lsp.toml".source = ./kak/kak-lsp.toml;

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
      nix-zsh = "nix-shell --command zsh";
      nix-stray-roots = "nix-store --gc --print-roots | egrep -v '^(/nix/var|/run/\\w+-system|\\{memory)' | cut -d' ' -f1";
      setclip = "xclip -selection clipboard -in";
      getclip = "xclip -selection clipboard -out";
      e = "kak";
      less = ''\less -XFR'';
      info = "info --vi-keys";
      ls = "exa --color=automatic";
      l = "ls -l";
      ll = "l --group --header --links --extended --git";
      la = "ll -a";
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
    plugins = with pkgs; [
      tmuxPlugins.cpu
      tmuxPlugins.resurrect
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
    ];
  };

  home.keyboard.layout = "de";

  home.language = {
    base = "en_US.UTF-8";
    address = "de_DE.UTF-8";
    monetary = "de_DE.UTF-8";
    paper = "de_DE.UTF-8";
    time = "de_DE.UTF-8";
  };

  home.stateVersion = "19.03";

  services.lorri.enable = true;

  systemd.user.services = {
    onedrive = {
      Unit = {
        Description = "OneDrive Free Client";
        Documentation = "man:onedrive(1)";
        After = [ "local-fs.target" "network.target" ];
      };

      Service = {
        ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor";
        Restart = "on-abnormal";
      };

      Install = {
        WantedBy = [ "multi-user.target" ];
      };
    };
  };
}
