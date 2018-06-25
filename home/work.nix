{ pkgs, ... }:

{
  imports = [ ./user-common.nix ];

  home.packages = [
    pkgs.arcanist
    pkgs.cabal-install
    pkgs.ghc
    pkgs.gmp
    pkgs.jetbrains.idea-community
    pkgs.krb5Full
    pkgs.maven
    pkgs.ncurses
    pkgs.openjdk
    pkgs.openldap
    pkgs.sssd
    pkgs.stack
  ];

  programs.git = {
    enable = true;
    userEmail = "sebastian.graf@kit.edu";
  };
}
