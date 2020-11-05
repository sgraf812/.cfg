{ pkgs, lib, config, ... }:

# Worth considering:
# - cbatticon: Better battery icon
# - home-manager.useGlobalPkgs: See https://rycee.gitlab.io/home-manager/#sec-install-nixos-module
# - grobi: Alternative to autorandr?

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

  myThunar = with pkgs; xfce.thunar.override {
    thunarPlugins = [
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.tumbler
    ];
  };

  i3lock-options = "--ignore-empty-password --image ${./wallpapers/haskell.png}";

in

{
  imports = [
    ./user-common.nix
    ./email.nix
  ];

  home.packages = with pkgs; [
    discord
    file
    gnome3.dconf # some tools need this to preserve settings
    google-chrome
    gucharmap
    # gcc_multi # ld.bfd conflicts with binutils-wapper's
    hicolor-icon-theme
    htop
    ncat
    nomacs
    okular
    pavucontrol
    pmutils
    powertop
    python
    skype
    spotify
    texlive.combined.scheme-full
    thunderbird
    myThunar
    # virtmanager # Needs virtualisation.libvirtd.enable = true; in configuration.nix and is currently deactivated
    vlc
    w3m
    xorg.xprop
    xarchiver
  ];

  accounts.email.accounts.private.primary = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
#    theme = {
#      name = "Adapta";
#      package = pkgs.adapta-gtk-theme;
#    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code";
      package = pkgs.fira-code;
    };
    settings = {
      "font_size" = "16";
      "shell" = "${pkgs.zsh}/bin/zsh --login";
      "enable_audio_bell" = "no";
    };
  };

  programs.firefox.enable = true;

  programs.ssh = {
    # enable = true;
  };

  programs.git.userEmail = "sgraf1337@gmail.com";

  programs.zsh.shellAliases = {
    ssh = "TERM=xterm-256color ssh";
    upd = "sudo nix-channel --update && nix-channel --update && sudo nixos-rebuild switch && home-manager switch && . ~/.zshrc";
    xrandr-hdmi = "xrandr --output HDMI-1 --auto";
    xrandr-hdmi-mirror = "xrandr-hdmi --same-as eDP-1";
    xrandr-hdmi-above = "xrandr-hdmi --above eDP-1";
    xrandr-hdmi-off = "xrandr-hdmi --off";
  };

  programs.rofi = {
    enable = true;
    theme = "sidebar";
    font = "Ubuntu medium 16";
    terminal = "${pkgs.kitty}/bin/kitty";
  };

  programs.skim = {
    enable = false;
    enableBashIntegration = true;
    enableZshIntegration = true;
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
    defaultCommand = "fd --type f";
  };

  programs.vscode = {
    enable = true;
  };

  programs.autorandr = {
    enable = true;
    profiles =
      let
        # TODO: This probably belongs in hardware-configuration.nix
        fingerprints = {
          thinkpad = "00ffffffffffff0006af3d3100000000001a0104a51f1178028d15a156529d280a505400000001010101010101010101010101010101143780b87038244010103e0035ae100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343048414e30332e31200a003b";
          benq24 = "00ffffffffffff0009d1a778455400002018010380351e782eba45a159559d280d5054a56b80810081c08180a9c0b300d1c001010101023a801871382d40582c4500132a2100001e000000ff0037384530323839343031390a20000000fd00324c1e5311000a202020202020000000fc0042656e5120474c32343530480a0150020322f14f90050403020111121314060715161f2309070765030c00100083010000023a801871382d40582c4500132a2100001f011d8018711c1620582c2500132a2100009f011d007251d01e206e285500132a2100001e8c0ad08a20e02d10103e9600132a21000018000000000000000000000000000000000000000000eb";
        };
      in
      {
        mobile = {
          fingerprint.eDP-1 = fingerprints.thinkpad;
          config.eDP-1 = {
            enable = true;
            primary = true;
            #crtc = 0;
            mode = "1920x1080";
            position = "0x0";
            rate = "60.05";
            dpi = 132;
          };
        };
        "docked-home" = {
          fingerprint.eDP-1 = fingerprints.thinkpad;
          fingerprint.HDMI-1 = fingerprints.benq24;
          config.eDP-1 = {
            enable = true;
            primary = false;
            #crtc = 0;
            mode = "1920x1080";
            position = "0x1080";
            rate = "60.05";
            dpi = 132;
          };
          config.HDMI-1 = {
            enable = true;
            primary = true;
            #crtc = 1;
            mode = "1920x1080";
            position = "0x0";
            rate = "60.00";
            dpi = 96;
          };
        };
      };
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

  home.file = {
    ".background-image".source = ./wallpapers/haskell.png;
  };

  home.extraProfileCommands = ''
    if [[ -d "$out/share/applications" ]] ; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
    fi
  '';

  systemd.user.services =
    let
      locker = pkgs.runCommand "transfer-sleep-lock" { buildInputs = [ pkgs.makeWrapper ]; } ''
        makeWrapper "${./xss-lock/transfer-sleep-lock-i3lock.sh}" $out \
          --set i3lock_options "${i3lock-options}" \
          --prefix PATH : ${pkgs.stdenv.lib.makeBinPath [ pkgs.bash pkgs.i3lock ]}
      '';
    in {
      clipit = graphicalService "X11 Clipboard manager" "${pkgs.clipit}" "clipit -n";
      # Touchpad gestures
      libinput-gestures = graphicalService "libinput gestures" "${pkgs.libinput-gestures}" "libinput-gestures";
      alttab = graphicalService "alttab" "${pkgs.alttab}" "alttab -d 1 -i 128x128 -t 128x196";
      lightsonplus = graphicalService "lightsonplus" "${pkgs.lightsonplus}" "lightson+";
      # dropbox only allows 3 devices in its free plan, so we are only installing it at home
      dropbox = graphicalService "Dropbox as a system service" "${pkgs.dropbox}" "dropbox";
      xss-lock = graphicalService "X screensaver locker" "${pkgs.xss-lock}" "xss-lock -s $XDG_SESSION_ID --transfer-sleep-lock -- ${locker}";
    };

  services.udiskie.enable = true;
  services.network-manager-applet.enable = true;

  services.polybar = 
    let
      path = with pkgs; [
        i3
        dmenu 
        polybar-spotify
        pavucontrol
        # xorg.xmessage
      ];
    in {
      enable = true;
      package = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };
      script = "PATH=${lib.makeBinPath path}:$PATH polybar top &";
      config = ./polybar/config;
    };

  services.picom = {
    enable = true;
    vSync = true;
  };

  # Doesn't find the config file. Maybe with 20.03
  # services.xsuspender.enable = true;

  xsession = {
    enable = true;

    pointerCursor = {
      name = "Vanilla-DMZ";
      package = pkgs.vanilla-dmz;
      size = 40;
    };

    windowManager.i3 = {
      enable = true;
      config = let modifier = "Mod4"; in {
        bars = [];

        modifier = "${modifier}";

        keybindings =
          let
            left = "h";
            right = "l";
            up = "k";
            down = "j";
          in lib.mkOptionDefault {
            "${modifier}+Return" = "exec cd $(${pkgs.xcwd}/bin/xcwd) && ${pkgs.kitty}/bin/kitty";
            "${modifier}+d" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show drun";
            "${modifier}+Shift+x" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock -n ${i3lock-options}";
            "${modifier}+b" = "split h";
            "${modifier}+${left}" = "focus left";
            "${modifier}+${down}" = "focus down";
            "${modifier}+${up}" = "focus up";
            "${modifier}+${right}" = "focus right";
            "${modifier}+Shift+${left}" = "move left";
            "${modifier}+Shift+${down}" = "move down";
            "${modifier}+Shift+${up}" = "move up";
            "${modifier}+Shift+${right}" = "move right";

            "${modifier}+p" = "focus output up";
            "${modifier}+Shift+p" = "move workspace to output up";

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
            { class = "Nm-connection-editor"; } # Although WM_CLASS also lists a lowercase version, that doesn't seem to work
            { class = "Pavucontrol"; }
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

      extraConfig = ''
          # Screenshots -- these have to be --release bindings
          bindsym --release Print exec ${pkgs.scrot}/bin/scrot -e 'mv $f ~/Pictures/Screenshots/'
          bindsym --release Shift+Print exec ${pkgs.scrot}/bin/scrot -s -e 'mv $f ~/Pictures/Screenshots/'
      '';
    };
  };
}
