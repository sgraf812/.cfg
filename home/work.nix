{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./modules/kitty.nix
  ];

  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
  ];

  programs.git.settings.user.email = "sgraf1337@gmail.com";

  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
  };

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
      upd = "nix flake update --flake /home/sg/code/nix/config/ && home-manager switch -b bak --flake /home/sg/code/nix/config/ && . ~/.zshrc";
    };
  };

  # Otherwise we don't see $NIX_PATH
  systemd.user.systemctlPath = "/bin/systemctl";
}
