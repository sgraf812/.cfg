{ pkgs, lib, ... }:

let
  addMirrorAboveOff = baseAliases: lib.fold (alias: a: a // {
    "${alias}-mirror" = "${alias} --same-as eDP-1";
    "${alias}-above" = "${alias} --above eDP-1";
    "${alias}-off" = "${alias} --off";
  }) baseAliases (builtins.attrNames baseAliases);

in

{
  imports = [ ];

  home.packages = with pkgs; [
    xorg.xrandr
    arandr # Useful for a more visual approach than xrandr
  ];

  # Use xrandr convenience aliases for unknown configs:
  programs.zsh.shellAliases = addMirrorAboveOff ({
    xrandr-dp1 = "xrandr --output DP-1 --auto";
    xrandr-dp2 = "xrandr --output DP-2 --auto";
    xrandr-hdmi = "xrandr --output HDMI-1 --auto";
  });

  # Use autorandr for good defaults in recognised configs:
  programs.autorandr = {
    enable = true;
    profiles =
      let
        # Generated by `autorandr --fingerprints`
        # TODO: This probably belongs in hardware-configuration.nix
        fingerprints = {
          thinkpad = "00ffffffffffff0006af3d3100000000001a0104a51f1178028d15a156529d280a505400000001010101010101010101010101010101143780b87038244010103e0035ae100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343048414e30332e31200a003b";
          benq24 = "00ffffffffffff0009d1a778455400002018010380351e782eba45a159559d280d5054a56b80810081c08180a9c0b300d1c001010101023a801871382d40582c4500132a2100001e000000ff0037384530323839343031390a20000000fd00324c1e5311000a202020202020000000fc0042656e5120474c32343530480a0150020322f14f90050403020111121314060715161f2309070765030c00100083010000023a801871382d40582c4500132a2100001f011d8018711c1620582c2500132a2100009f011d007251d01e206e285500132a2100001e8c0ad08a20e02d10103e9600132a21000018000000000000000000000000000000000000000000eb";
          helene = "00ffffffffffff001e6d485a61070500031b01036c331d78ea6275a3554fa027125054a76b80714f81c08100818095009040a9c0b300023a801871382d40582c4500fe221100001e000000fd00384b1e530f000a202020202020000000fc0032344d4233350a202020202020000000ff003730334e54574739503536390a00fc";
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
        "docked-helene" = {
          fingerprint.eDP-1 = fingerprints.thinkpad;
          fingerprint.DP-1 = fingerprints.helene;
          config.eDP-1 = {
            enable = true;
            primary = false;
            #crtc = 0;
            mode = "1920x1080";
            position = "0x1080";
            rate = "60.05";
            dpi = 132;
          };
          config.DP-1 = {
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

}