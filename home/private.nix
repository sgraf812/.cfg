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
    ./common.nix
    modules/ghc-dev.nix
    modules/kakoune.nix
    modules/lazygit.nix
    modules/rclone.nix
    modules/rclone.nix
  ];

  home.packages = with pkgs; [
    audacity
    cabal2nix
    cabal-install
    ghc
    (pkgs.writeShellScriptBin "ghc96" ''exec -a $0 ${haskell.compiler.ghc96}/bin/ghc "$@"'')
    (pkgs.writeShellScriptBin "ghc98" ''exec -a $0 ${haskell.compiler.ghc98}/bin/ghc "$@"'')
    (pkgs.writeShellScriptBin "ghc910" ''exec -a $0 ${haskell.compiler.ghc910}/bin/ghc "$@"'')
    gimp
    # gthumb # can crop images # segfaults in ubuntu...
    haskellPackages.ghcid
    # haskellPackages.hkgr # Hackage release management, but it's broken
    haskellPackages.lhs2tex
    haskellPackages.hasktags
    haskell-language-server
    # nofib-analyse # see overlay
    p7zip
    pdfpc
    stack
    # stack2nix # broken
    sqlcsv
  ];

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

  services.rclone = {
    enable = lib.mkDefault true;
    mounts = {
      pcloud   = { from = "pCloud:/";   to = "${config.home.homeDirectory}/mnt/pCloud"; };
    };
  };
}
