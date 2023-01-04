{ pkgs, lib, kitty-fix, ... }:

{
  imports = [ ];

  programs.kitty = {
    enable = true;
    package = kitty-fix.kitty;
    font = {
      name = "Iosevka";
      package = pkgs.iosevka;
    };
    settings = {
      bold_font = "Iosevka Bold";
      italic_font = "Iosevka Italic";
      bold_italic_font = "Iosevka Bold Italic";
      font_size = 14;
      shell = "${pkgs.zsh}/bin/zsh --login";
      enable_audio_bell = false;
    };
  };

  programs.zsh.shellAliases = {
    # https://sw.kovidgoyal.net/kitty/kittens/ssh/
    # I'm not using any of the features, plus it leads to errors when I work
    # from home and want to SSH into another work machine
    # ssh = "${pkgs.kitty}/bin/kitty +kitten ssh";
  };
}
