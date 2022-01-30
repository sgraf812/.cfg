{ pkgs, lib, ... }:

{
  imports = [ ];

  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
      };
      git.pull.mode = "rebase";
    };
  };

  programs.zsh.shellAliases = {
    lg = "lazygit";
  };
}
