{ pkgs, ... }:

{
  imports = [ ./user-common.nix ];

  home.packages = with pkgs; [
    cabal-install
    gcc_multi
    ghc
    gmp
    jetbrains.idea-community
    krb5Full
    maven
    # Mendeley pulls Qt and more stuff that needs to be compiled
    # mendeley
    ncurses
    openjdk11
    openldap
    (openssh.override {
      withKerberos = true;
      withGssapiPatches = true;
    })
    sssd
    # ycomp
  ];

  programs.git.userEmail = "sebastian.graf@kit.edu";

  programs.zsh = {
    shellAliases = {
      # Can't use the git binary from nixpkgs :/
      git = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin git";
      ssh = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin ssh";
    };
    localVariables = {
      USE_TMUX = "yes";
    };
  };
}
