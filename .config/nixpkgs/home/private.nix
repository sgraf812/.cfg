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
    modules/xrandr.nix
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
    zoom-us
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
      name = "Iosevka 14";
      package = pkgs.iosevka;
    };
    settings = {
      font_size = 14;
      shell = "${pkgs.zsh}/bin/zsh --login";
      enable_audio_bell = false;
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
  services.blueman-applet.enable = true;

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
      # Apparently the service doesn't see the XSession and thus can't find
      # the primiary display
      # script = "MONITOR=$(${pkgs.xorg.xrandr}/bin/xrandr | grep -E ' connected primary [1-9]+' | cut -d' ' -f1) \\\
      script = "PATH=${pkgs.fontconfig}/bin:${lib.makeBinPath path}:$PATH polybar top &";
      # See also https://cdn.materialdesignicons.com/5.4.55/ for icon hexcodes
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
