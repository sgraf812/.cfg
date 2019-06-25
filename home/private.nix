{ pkgs, ... }:

{
  imports = [ ./user-common.nix ];
  home.packages = [
  	openssh
  ];
  programs.git.userEmail = "sgraf1337@gmail.com";
}
