{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./modules/kitty.nix
  ];

  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    #mendeley # Broken in 22.11 because of qt-webkit. Also in browser now
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
      # I'm not sure we need the following line; it appears that this var is set already
      #NIX_PATH = "nixpkgs=$HOME/.nixpkgs/stable:unstable=$HOME/.nixpkgs/unstable\${NIX_PATH:+:}$NIX_PATH";
    };
    shellAliases = {
      afs-lease = "kinit -l 7d sgraf; aklog";
      upd = "sudo apt update && sudo apt upgrade --yes && nix flake update /home/sgraf-local/code/nix/config/ && home-manager switch -b bak --flake /home/sgraf-local/code/nix/config/ && . ~/.zshrc";
      afs-serve  = ''() { trap "pushd ~sgraf/public_html/   > /dev/null  && rm -rf $(echo "$@" | xargs -n1 basename); popd > /dev/null; return" EXIT INT; cp "$@" ~sgraf/public_html/   && read; }'';
      afs-iserve = ''() { trap "pushd ~sgraf/public_html/i/ > /dev/null  && rm -rf $(echo "$@" | xargs -n1 basename); popd > /dev/null; return" EXIT INT; cp "$@" ~sgraf/public_html/i/ && read; }'';
    };
  };

  # Otherwise we don't see $NIX_PATH
  systemd.user.systemctlPath = "/bin/systemctl";
}
