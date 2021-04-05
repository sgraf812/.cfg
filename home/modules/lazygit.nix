{ pkgs, lib, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [ lazygit ];

  xdg.configFile."lazygit/config.yml".text = lib.generators.toYAML {} {
    gui.theme = {
    };
  };

  programs.zsh.shellAliases = {
    lg = "lazygit";
  };
}
