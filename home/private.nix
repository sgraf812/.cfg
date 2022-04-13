{ pkgs, lib, unstable, ... }:

# Worth considering:
# - home-manager.useGlobalPkgs: See https://rycee.gitlab.io/home-manager/#sec-install-nixos-module

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
    # modules/email.nix # doesn't currently work
    ./common.nix
  ];

  home.packages = with pkgs; [
    binutils # ar and stuff
    # discord # somehow broken.. can't satisfy libasound
    file
    gnome3.dconf # some tools need this to preserve settings
    gnome3.gnome-tweaks
    unstable.gnomeExtensions.pop-shell
    google-chrome
    gucharmap
    # gcc_multi # ld.bfd conflicts with binutils-wapper's
    hicolor-icon-theme
    htop
    libreoffice
    ncat
    okular
    pavucontrol
    pmutils
    powertop
    python
    skype
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

  programs.kitty = {
    enable = true;
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

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin.override {
      # See nixpkgs' firefox/wrapper.nix to check which options you can use
      cfg.enableGnomeExtensions = true;
    };
  };

  programs.ssh = {
    # enable = true;
  };

  programs.git.userEmail = "sgraf1337@gmail.com";

  programs.zsh.shellAliases = {
    ssh = "${pkgs.kitty}/bin/kitty +kitten ssh";
    upd = "nix flake update /home/sgraf/code/nix/config/ && sudo nixos-rebuild switch --flake /home/sgraf/code/nix/config/ && . ~/.zshrc";
  };

  programs.vscode = {
    enable = true;
  };

  xdg = {
    enable = true;
    dataFile = {
      "icons/hicolor/128x128/apps/spotify.png".source = "${pkgs.spotify}/share/spotify/icons/spotify-linux-128.png";
      "icons/hicolor/128x128/apps/code.png".source = ./vscode/icon-128.png;
    };

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

  home.extraProfileCommands = ''
    if [[ -d "$out/share/applications" ]] ; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
    fi
  '';

  systemd.user.services = {
    # Touchpad gestures, accessed by the smooth gestures gnome extension
    libinput-gestures = graphicalService "libinput gestures" "${pkgs.libinput-gestures}" "libinput-gestures";
    # dropbox only allows 3 devices in its free plan, so we are only installing it at home
    dropbox = graphicalService "Dropbox as a system service" "${pkgs.dropbox}" "dropbox";
  };

  services.gnome-keyring.enable = true;
}
