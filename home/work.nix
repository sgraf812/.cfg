{ pkgs, ... }:

{
  imports = [ ./user-common.nix ];

  home.packages = [
    pkgs.cabal-install
    pkgs.ghc
    pkgs.gmp
    pkgs.jetbrains.idea-community
    pkgs.krb5Full
    pkgs.maven
    # Mendeley pulls Qt and more stuff that needs to be compiled
    # pkgs.mendeley
    pkgs.ncurses
    pkgs.openjdk11
    pkgs.openldap
    (pkgs.openssh.override {
      withKerberos = true;
      withGssapiPatches = true;
    })
    pkgs.sssd
    pkgs.stack
  ];

  programs.git = {
    enable = true;
    userEmail = "sebastian.graf@kit.edu";
  };
}
