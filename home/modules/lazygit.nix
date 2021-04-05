{ pkgs, lib, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [ lazygit ];

  xdg.configFile."lazygit/config.yml".text = lib.generators.toYAML {} {
    # gui.theme = {
    #   selectedLineBgColor = "reverse"; # can't see bold or w/e
    #   selectedRangeBgColor = "reverse";
    # };
  };

  programs.zsh.shellAliases = {
    lg = "lazygit";
  };
}
