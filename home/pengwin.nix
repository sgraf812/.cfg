{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    texlive.combined.scheme-full
  ];

  programs.git.userEmail = "sgraf1337@gmail.com";

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
      export DISPLAY=$(${pkgs.iproute2}/bin/ip route | grep default | awk '{print $3; exit;}'):0.0
    '';
    shellAliases = {
      upd = "sudo apt update && sudo apt upgrade --yes && nix flake update /home/sgraf/code/nix/config/ && home-manager switch -b bak --flake /home/sgraf/code/nix/config/ && . ~/.zshrc";
    };
  };

  home.username = "sgraf";
  home.homeDirectory = "/home/sgraf";
}
