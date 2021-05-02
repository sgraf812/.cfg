{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  targets.genericLinux.enable = true;

  home.username = "sgraf-local";
  home.homeDirectory = "/home/sgraf-local/";

  home.packages = with pkgs; [
    mendeley
    pdftk
    vit
  ];

  programs.git.userEmail = "sebastian.graf@kit.edu";

  programs.taskwarrior.enable = true;

  programs.zsh = {
    localVariables = {
      USE_TMUX = "yes";
    };
    sessionVariables = {
      GIT_SSL_CAINFO = "/etc/ssl/certs/ca-certificates.crt";
      CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
      # NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      # fix locales for Nix on Ubuntu
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };
    shellAliases = {
      afs-lease = "kinit -l 7d sgraf; aklog";
      upd = "sudo apt update && sudo apt upgrade --yes && nix-channel --update && home-manager switch && . ~/.zshrc";
      afs-serve  = ''() { cp "$@" ~sgraf/public_html/   && read; (cd ~sgraf/public_html/   && rm $(echo "$@" | xargs -n1 basename);); }'';
      afs-iserve = ''() { cp "$@" ~sgraf/public_html/i/ && read; (cd ~sgraf/public_html/i/ && rm $(echo "$@" | xargs -n1 basename);); }'';
    };
  };
}
