{ pkgs, ... }:

{
  imports = [ ./user-common.nix ];

  home.packages = [
    pkgs.krb5Full
    pkgs.openldap
    pkgs.sssd
  ];

  programs.git = {
    enable = true;
    userEmail = "sebastian.graf@kit.edu";
  };
}
