{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.rclone;
in
{
  options.services.rclone = {
    enable = mkEnableOption "rclone";
    package = mkPackageOption pkgs "rclone";

    mounts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          from = mkOption {
            type = types.str;
            example = ''dropbox:/shared'';
            description = ''The rclone remote path to mount'';
          };
          to = mkOption {
            type = types.str;
            example = ''/mnt/dropbox'';
            description = ''The mountpoint in the local filesystem'';
          };
        };
      });
      default = {};
      example = ''{ dropbox = { from = "dropbox:/shared"; to = "/mnt/dropbox"; }; }'';
      description = ''
        An attribute set of mount mappings
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.rclone ];

    systemd.user.services = flip mapAttrs cfg.mounts (name: mapping: {
      # Inspired by https://gist.github.com/kabili207/2cd2d637e5c7617411a666d8d7e97101
      Unit = {
        Description = "rclone: ${name}";
        Documentation = "man:rclone(1)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "notify";
        ExecStartPre="/bin/sh -c '${pkgs.coreutils}/bin/mkdir -p ${mapping.to}; fusermount -uz ${mapping.to} || true'";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount \
            --config=%h/.config/rclone/rclone.conf \
            --vfs-cache-mode full \
            --buffer-size 5M \
            --vfs-read-ahead 10M \
            --vfs-cache-max-size 500M \
            --log-level INFO \
            --log-file /tmp/rclone-${name}.log \
            --file-perms 0600 \
            --dir-perms 0700 \
            ${mapping.from} ${mapping.to}
        '';
        # -z: https://stackoverflow.com/a/25986155/388010
        ExecStop = "fusermount -uz ${mapping.to} || true";
        Restart = "on-abnormal";
        RestartSec=5;
        # fusermount needs to be wrapped in NixOS. Otherwise we take the native
        # binary; the one from ${pkgs.fuse} leads to a permission error in
        # `rclone mount`.
        # Same happens on Ubuntu; we need the fusermount (and friends) from /bin/.
        Environment="PATH=/run/wrappers/bin/:/bin/:$PATH";
      };

      Install = {
        WantedBy = [ "default.target" ]; # resolves to multi-user.target (server) or graphical.target
      };
    });
  };
}
