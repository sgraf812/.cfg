{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
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
    shellAliases = {
      upd = "sudo apt update && sudo apt upgrade --yes && nix-channel --update && home-manager switch && . ~/.zshrc";
    };
  };

  home.username = "sgraf";
  home.homeDirectory = "/home/sgraf";
}
