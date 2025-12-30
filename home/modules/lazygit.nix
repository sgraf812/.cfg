{ pkgs, lib, ... }:

{
  imports = [ ];

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      gui.theme = {
      };
      git.pull.mode = "rebase";
    };
  };
}
