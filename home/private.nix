{ pkgs, lib, config, ... }:

let

  fork = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "2c074fc6c8d278a8e8e7c3bfec42b7e762199fb4";
    sha256 = "0hsj1d5f6n7gixqkygxysrfzvjpllzydj5q95lzjf1r6j00fcs5l";
    fetchSubmodules = false;
  }) {};

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

  myThunar = with pkgs; xfce.thunar.override {
    thunarPlugins = [
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.tumbler
    ];
  };

in

{
  imports = [
    ./user-common.nix
    ./email.nix
    # configure mopidy with home-manager
    (fetchTarball https://github.com/lightdiscord/mopidy-nix/archive/master.tar.gz)
  ];

  home.packages = with pkgs; [
    discord
    file
    gucharmap
    gcc_multi
    hicolor-icon-theme
    htop
    ncat
    networkmanager_dmenu
    nomacs
    okular
    pavucontrol
    pmutils
    python
    spotify
    myThunar
    vlc
    vscode
    w3m
    xorg.xprop
  ];

  accounts.email.accounts.private.primary = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Adapta";
      package = pkgs.adapta-gtk-theme;
    };
  };

  programs.alacritty = {
    enable = true;
    settings."shell" = {
      program = "${pkgs.zsh}/bin/zsh";
      args = [ "--login" ];
    };
  };

  programs.firefox.enable = true;

  programs.ssh = {
    # enable = true;
  };

  programs.git.userEmail = "sgraf1337@gmail.com";

  programs.zsh.shellAliases = {
    ssh = "TERM=xterm-256color ssh";
  };

  programs.rofi = {
    enable = true;
    theme = "sidebar";
    font = "Roboto medium 14";
    terminal = "${pkgs.alacritty}/bin/alacritty";
  };

  programs.skim = {
    enable = false;
    enableBashIntegration = true;
    enableZshIntegration = true;
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
    defaultCommand = "fd --type f";
  };

  xdg = {
    enable = true;
    dataFile = {
      "icons/hicolor/128x128/apps/spotify.png".source = "${pkgs.spotify}/share/spotify/icons/spotify-linux-128.png";
      "icons/hicolor/128x128/apps/alacritty.png".source = ./alacritty/icon-128.png;
      "icons/hicolor/128x128/apps/code.png".source = ./vscode/icon-128.png;
    };
  };

  home.extraProfileCommands = ''
    if [[ -d "$out/share/applications" ]] ; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
    fi
  '';

  systemd.user.services = {
    # Clipboard manager
    clipit = graphicalService "X11 Clipboard manager" "${pkgs.clipit}" "clipit -n";
    # Touchpad gestures
    libinput-gestures = graphicalService "libinput gestures" "${pkgs.libinput-gestures}" "libinput-gestures";
    alttab = graphicalService "alttab" "${fork.alttab}" "alttab -d 1 -i 128x128 -t 128x196";
    lightsonplus = graphicalService "lightsonplus" "${pkgs.lightsonplus}" "lightson+";
  };

  services.udiskie.enable = true;

  services.polybar = 
    let
      path = [pkgs.i3 pkgs.networkmanager_dmenu pkgs.dmenu];
    in {
      enable = true;
      package = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
        mpdSupport = true;
      };
      script = "PATH=${lib.makeBinPath path}:$PATH polybar top &";
      config = ./polybar/config;
    };

  services.screen-locker = {
    # runs xss-lock when the xsession is started, so needs
    #    xsession.enable = true;
    enable = true;
    lockCmd = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
    xautolockExtraOptions = [ "-lockaftersleep" ];
  };

  services.compton = {
    enable = true;
    vSync = "opengl-swc";
  };

  xsession = {
    # We need enable = true for .xsession to start xss-lock. But then
    # home-manager won't play nicely with the xsession started by the login
    # manager. Chaos!
    enable = true;

    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 40;
    };

    windowManager.i3 = {
      enable = true;
      config = let modifier = "Mod1"; in {
        assigns = {
          "0: firefox" = [{ class = "^Firefox$"; }];
          # Doesn't work
          # "99: spotify" = [{ class = "^Spotify$"; }];
        };

        bars = [];

        modifier = "${modifier}";

        keybindings =
          let
            left = "h";
            right = "l";
            up = "k";
            down = "j";
          in lib.mkOptionDefault {
            "${modifier}+Return" = "exec cd $(${pkgs.xcwd}/bin/xcwd) && ${pkgs.alacritty}/bin/alacritty";
            "${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show drun";
            "${modifier}+Shift+x" = "exec --no-startup-id ${pkgs.betterlockscreen}/bin/betterlockscreen -l dimblur";
            "${modifier}+b" = "split h";
            "${modifier}+${left}" = "focus left";
            "${modifier}+${down}" = "focus down";
            "${modifier}+${up}" = "focus up";
            "${modifier}+${right}" = "focus right";
            "${modifier}+Shift+${left}" = "move left";
            "${modifier}+Shift+${down}" = "move down";
            "${modifier}+Shift+${up}" = "move up";
            "${modifier}+Shift+${right}" = "move right";

            # For testing purposes
            #"${modifier}+a" = "exec ${pkgs.xorg.xmessage}/bin/xmessage hi";

            "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle";
            "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +3%";
            "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -3%";
            # Source #0 is a monitor of #1...
            "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute 1 toggle";

            # Deactivate window focus through arrow keys, so
            # that the alt+left is still 'back' in the browser
            "${modifier}+Left" = null;
            "${modifier}+Down" = null;
            "${modifier}+Up" = null;
            "${modifier}+Right" = null;
            "${modifier}+Shift+Left" = null;
            "${modifier}+Shift+Down" = null;
            "${modifier}+Shift+Up" = null;
            "${modifier}+Shift+Right" = null;
          };

        window = {
          titlebar = false;
          hideEdgeBorders = "both";
          commands = [ { command = "move to workspace \"99: spotify\""; criteria = { class = "Spotify"; }; } ];
        };

        floating = {
          criteria = [
            { "class" = "Pavucontrol"; }
          ];
        };

        startup = [
          # https://github.com/rycee/home-manager/issues/213
          { command = "systemctl --user restart polybar"; always = true; notification = false; }
          # Some pulseaudio modules depend on an X11 session
          { command = "systemctl --user restart pulseaudio"; always = true; notification = false; }
          # alttab
          { command = "systemctl --user restart alttab"; always = true; notification = false; }
        ];
      };
    };

    initExtra = ''
      ${pkgs.betterlockscreen}/bin/betterlockscreen -u ~/Pictures/lock &
    '';
  };

  services.mopidy = {
    enable = true;
    extensionPackages = [ pkgs.mopidy-spotify pkgs.mopidy-iris pkgs.mopidy-mopify ];
    configuration = ''
      [spotify]
      ${builtins.readFile ./keys/private/spotify.txt}
      bitrate = 320
    '';
  };
}
