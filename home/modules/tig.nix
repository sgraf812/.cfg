{ pkgs, lib, ... }:

{
  imports = [ ];

  home.packages = with pkgs; [ gitAndTools.tig ];

  xdg.configFile."tig/config".text = ''
    bind status A !?git commit --amend
  '';
}
