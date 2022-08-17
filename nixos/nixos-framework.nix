# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ name, config, pkgs, inputs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./nixos-framework-hardware.nix
    inputs.nixos-hardware.nixosModules.framework
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Fix brightness control keys etc.
  # https://dov.dev/blog/nixos-on-the-framework-12th-gen
  boot.kernelParams = [ "module_blacklist=hid_sensor_hub" ];

  # Enable NTFS Fuse FS
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "nixos-framework"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant. Not needed when we have networkmanager.
  # networking.networkmanager = {
  #   enable = true;
  #   packages = [ pkgs.networkmanager-openvpn ];
  # };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.utf8";
    LC_IDENTIFICATION = "de_DE.utf8";
    LC_MEASUREMENT = "de_DE.utf8";
    LC_MONETARY = "de_DE.utf8";
    LC_NAME = "de_DE.utf8";
    LC_NUMERIC = "de_DE.utf8";
    LC_PAPER = "de_DE.utf8";
    LC_TELEPHONE = "de_DE.utf8";
    LC_TIME = "de_DE.utf8";
  };

  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    keyMap = "us";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cachix
    git
    htop
    openssh
    vim
    wget
  ];

  fonts = {
    enableDefaultFonts = true;
    fontDir.enable = true;

    fonts = with pkgs; [
      cascadia-code
      fira-code
      fira-code-symbols
      font-awesome_4
      iosevka
      material-design-icons # community
      noto-fonts
      noto-fonts-emoji
      roboto
      siji
      ubuntu_font_family
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        serif = [ "Ubuntu" "Roboto" ];
        sansSerif = [ "Ubuntu" "Roboto" ];
        monospace = [ "Iosevka" "Fira Code" "Cascadia Code" "Ubuntu" ];
      };
    };
  };

  programs.dconf.enable = true;
  services.dbus.enable = true;
  services.dbus.packages = with pkgs; [ dconf ];
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

  # Shoot things when there's less than 2% RAM
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 2;
  };

  # Install firmware updates
  services.fwupd.enable = true;
  services.fwupd.enableTestRemote = true;

  programs.zsh.enable = true;
  programs.thefuck.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.openvpn = {
    servers = {
      kit = {
        autoStart = false;
        updateResolvConf = true;
        config = ''
          client
          remote 141.52.8.19
          port 1194
          dev tap
          proto udp
          auth-user-pass
          nobind
          comp-lzo no
          tls-version-min 1.2
          ca ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
          verify-x509-name "C=DE, ST=Baden-Wuerttemberg, L=Karlsruhe, O=Karlsruhe Institute of Technology, OU=Steinbuch Centre for Computing, CN=ovpn.scc.kit.edu" subject
          cipher AES-256-CBC
          auth SHA384
          reneg-sec 43200
          verb 3
          script-security 2
        '';
      };
    };
  };

  security.pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
  security.rtkit.enable = true; # for Gnome

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.epson-escpr
    pkgs.gutenprint
    pkgs.gutenprintBin
  ];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.video.hidpi.enable = false;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "eu,us";
    xkbOptions = "eurosign:e, caps:swapescape";
    #dpi = 192;

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      #enable = true;
      #touchpad = {
      #  naturalScrolling = true;
      #  # We don't want natural scrolling on the track point or mouse
      #  additionalOptions = ''MatchIsTouchpad "on"'';
      #  accelSpeed = "0.6";
      #};
    };
  };
  services.gnome.chrome-gnome-shell.enable = true;

  users.mutableUsers = false;
  users.users.sgraf = {
    createHome = true;
    home = "/home/sgraf";
    group = "users";
    description = "Sebastian Graf";
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "input" "disk" "networkmanager" "libvirtd" ];
    uid = 1000;
    shell = pkgs.zsh;
    hashedPassword = "$6$/XBcQHtEME$UA6R5al2se/3aodx8mV2XkhhMiAQ1qIBlVCgAOW5nYCtiZtmdj45Dp7DI/r.7AQQS1Op78VniNKgnKOza9TDS."; # mkpasswd -m sha-512
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5CKChZHMUIx7KYIYTgweK8oauSIdA8v2bQIPaO9ln6UwbecoryN7rvjJtV+KB46NG/2CmMBv/NEkkYz+9BU7CR0ierZUzMmvkfxqhlwXbvNpzqvngmSfY/0liHWF9H+/NaG3gY3e7kmM4Vl1MHpE4rzykFHahD9N3owOwbXXsIHXPNCPPZhJY654LLKC5YI1uQPuB8U7MXWKCd54nlL8ePBY7o+cElrOQXMdADAt60M9NH87nhiqq6t4Ytyp72b3oVrDME0bBdtsIu5aqFPqeGk+90Qqdr6Vtwren+mVdZITpH5PelCFoiRcUjuqza+qwIB5hG7IFawtWGvfgqSeB Sebastian@Sebastian-PC"
    ];
  };
  nix.trustedUsers = [ "root" "@wheel" ]; # for user-mode cachix

  # libvirtd doesn't properly set up resolution and GPU acceleration
  #
  # boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
  # boot.kernelModules = [ "kvm-intel" ];
  # virtualisation.kvmgt = {
  #   enable = true;
  #   vgpus = {
  #     "i915-GVTg_V5_8" = { # needs to be updated to this laptop
  #       uuid = "78afde9e-24fe-11ea-89ab-c3e54fc4e17c";
  #     };
  #   };
  # };
  # virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "sgraf" ];
  # Unfortunately the extension pack isn't built by Hydra (unfree) and I really
  # don't want to rebuild this all the time
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "sgraf" ];


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
