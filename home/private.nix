{ pkgs, ... }:

{
  imports = [ ./user-common.nix ];
  home.packages = [
  	openssh
  ];
  programs.git = {
    enable = true;
    userEmail = "sgraf1337@gmail.com";
  };
}
