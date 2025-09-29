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

  services.rclone = {
    enable = lib.mkDefault true;
    mounts = {
      pcloud   = { from = "pCloud:/";   to = "${config.home.homeDirectory}/mnt/pCloud"; };
    };
  };
}
