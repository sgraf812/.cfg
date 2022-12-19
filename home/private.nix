{ config, pkgs, lib, unstable, ... }:

let

  graphicalService = descr: pkg: exe: {
    Unit = {
      Description = "${descr}";
      Documentation = "man:${exe}(1)";
      After = "graphical-session-pre.target";
      PartOf = "graphical-session.target";
    };

    Service = {
      ExecStart = "${pkg}/bin/${exe}";
      Restart = "on-abnormal";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

in

{
  imports = [
    ./common.nix
    ./modules/dconf.nix
    ./modules/kitty.nix
    ./modules/rclone.nix
  ];

  home.packages = with pkgs; [
    binutils # ar and stuff
    # discord # somehow broken.. can't satisfy libasound
    file
    dconf # some tools need this to preserve settings
    gnome.gnome-tweaks
    gnome.gnome-shell-extensions
    gnomeExtensions.bluetooth-quick-connect
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.system-monitor
    gnomeExtensions.impatience
    gnomeExtensions.pop-shell
    gnomeExtensions.window-calls-extended
    gnomeExtensions.vertical-overview
    google-chrome
    gucharmap
    # gcc_multi # ld.bfd conflicts with binutils-wapper's
    hicolor-icon-theme
    htop
    libreoffice
    nmap
    okular
    pavucontrol
    pmutils
    powertop
    python
    spotify
    texlive.combined.scheme-full
    thunderbird
    # virtmanager # Needs virtualisation.libvirtd.enable = true; in configuration.nix and is currently deactivated
    vlc
    w3m
    xorg.xprop
    zoom-us

    # Haskell/Cabal/Stack stuff
    # haskell-ci # old version, can't get it to work on unstable either
    zlib.dev
    gmp.static
    ncurses
    numactl
  ];

  accounts.email.accounts.private.primary = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Plata-Noir-Compact";
      package = pkgs.plata-theme;
    };
  };

  programs.firefox.enable = true;

  programs.ssh = {
    # enable = true;
  };

  programs.git.userEmail = "sgraf1337@gmail.com";

  programs.zsh.shellAliases = {
    upd = "nix flake update /home/sgraf/code/nix/config/ && sudo nixos-rebuild switch --flake /home/sgraf/code/nix/config/ && . ~/.zshrc";
  };

  programs.vscode = {
    enable = true;
  };

  xdg = {
    enable = true;
    #dataFile = {
    #  "icons/hicolor/128x128/apps/spotify.png".source = "${pkgs.spotify}/share/spotify/icons/spotify-linux-128.png";
    #  "icons/hicolor/128x128/apps/code.png".source = ./vscode/icon-128.png;
    #};

    configFile."mimeapps.list".force = true; # https://github.com/nix-community/home-manager/issues/1213
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      };
    };
  };

  home.username = "sgraf";
  home.homeDirectory = "/home/sgraf";
  home.file = {
    ".background-image".source = ./wallpapers/haskell.png;
  };

  services.rclone = {
    enable = true;
    # dropbox only allows 3 devices in its free plan, so we are only installing it at home
    mounts.dropbox = { from = "Dropbox:/"; to = "${config.home.homeDirectory}/mnt/Dropbox"; };
  };

  systemd.user.services = {
    # Touchpad gestures, accessed by the smooth gestures gnome extension
    libinput-gestures = graphicalService "libinput gestures" "${pkgs.libinput-gestures}" "libinput-gestures";
  };

  services.gnome-keyring.enable = true;
}
