{ pkgs, lib, config, ... }:

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
    modules/email.nix
    ./common.nix
  ];

  home.packages = with pkgs; [
    discord
    file
    gnome3.dconf # some tools need this to preserve settings
    gnome3.gnome-tweaks
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
      name = "Iosevka 14";
      package = pkgs.iosevka;
    };
    settings = {
      font_size = 14;
      shell = "${pkgs.zsh}/bin/zsh --login";
      enable_audio_bell = false;
    };
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin.override {
      # See nixpkgs' firefox/wrapper.nix to check which options you can use
      cfg.nableGnomeExtensions = true;
    };
  };

  programs.ssh = {
    # enable = true;
  };

  programs.git.userEmail = "sgraf1337@gmail.com";

  programs.zsh.shellAliases = {
    ssh = "${pkgs.kitty}/bin/kitty +kitten ssh";
    upd = "sudo nix-channel --update && nix-channel --update && sudo nixos-rebuild switch && home-manager switch -b bak && . ~/.zshrc";
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
