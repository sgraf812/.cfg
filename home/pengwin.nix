{ pkgs, ... }:

{
  imports = [ ./private.nix ];

  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    texlive.combined.scheme-full
  ];

  programs.git.settings.user.email = "sgraf1337@gmail.com";

  programs.zsh = {
    localVariables = {
      USE_TMUX = "no";
    };
    sessionVariables = {
      GIT_SSL_CAINFO = "/etc/ssl/certs/ca-certificates.crt";
      CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
      # NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      # fix locales for Nix on Ubuntu
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };
    envExtra = ''
      # https://x410.dev/cookbook/wsl/using-x410-with-wsl2/ Option 1 did not work in Loccum
      # https://x410.dev/cookbook/wsl/using-x410-with-wsl2/ Option 2 stopped working because it returned wrong IP
      # https://x410.dev/cookbook/wsl/using-x410-with-wsl2/ Option 3 is good, but requires .wslconfig change
      export DISPLAY=localhost:0.0
      ${pkgs.xorg.setxkbmap}/bin/setxkbmap eu # Normally set in OS settings/NixOS module
    '';
    shellAliases = {
      upd = "sudo apt update && sudo apt upgrade --yes && nix flake update --flake /home/sgraf/code/nix/config/ && home-manager switch -b bak --flake /home/sgraf/code/nix/config/ && (git -C /home/sgraf/code/nix/config diff --quiet -- flake.lock || git -C /home/sgraf/code/nix/config commit -m 'flake.lock bump' -- flake.lock) && . ~/.zshrc";
    };
  };

  # programs.doom-emacs.enable = false;
  services.rclone.enable = false;

  home.username = "sgraf";
  home.homeDirectory = "/home/sgraf";
}
