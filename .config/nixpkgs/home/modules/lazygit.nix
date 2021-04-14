{ pkgs, lib, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [ lazygit ];

  xdg.configFile."lazygit/config.yml".text = lib.generators.toYAML {} {
    gui.theme = {
    };
    git.pull.mode = "rebase";
  };

  programs.zsh.shellAliases = {
    lg = "lazygit";
  };
}
