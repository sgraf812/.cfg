# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-lt"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant. Not needed when we have networkmanager.
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    blueman
    brightnessctl
    cachix
    git
    htop
    openssh
    vim
    wget
  ];
 
  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    font-awesome_4
    material-design-icons # community
    noto-fonts
    noto-fonts-emoji
    roboto
    siji
  ];

  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  # For completions mostly
  programs.zsh.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

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
          tls-version-min 1.2
          ca /etc/ssl/certs/T-TeleSec_GlobalRoot_Class_2.pem
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ 
    pkgs.epson-escpr
    pkgs.gutenprint
    pkgs.gutenprintBin
  ];

  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };

  hardware.bluetooth.enable = true;

  hardware.brightnessctl.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      # Lower brightness
      { keys = [ 224 ]; events = [ "key" "rep" ]; command = "${pkgs.brightnessctl}/bin/brightnessctl -n1 set 10%-"; }
      # Raise brightness
      { keys = [ 225 ]; events = [ "key" "rep" ]; command = "${pkgs.brightnessctl}/bin/brightnessctl -n1 set 10%+"; }
    ];
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "de";
    xkbOptions = "eurosign:e";
    dpi = 132;

    desktopManager = {
      default = "none";
      xterm.enable = false;
    };

    libinput = {
      enable = true;
      naturalScrolling = true;
      accelSpeed = "0.6";
    };

    # Although we start it in the user session, we need to enable it here in
    # order for lightdm to pick it up
    windowManager.i3.enable = true;
  };

  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;
  };

  services.redshift = {
    enable = true;
    provider = "geoclue2";
    temperature.day = 6500;
    temperature.night = 3500;
  };

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

  virtualisation.libvirtd.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
