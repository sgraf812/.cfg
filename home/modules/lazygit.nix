{ pkgs, lib, ... }:

{
  imports = [ ];

  programs.lazygit = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      gui.theme = {
      };
      git.pull.mode = "rebase";
      # Resolved conflicts stay unstaged until staged by hand during a rebase.
      git.autoStageResolvedConflicts = false;
    };
  };
}
