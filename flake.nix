{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    unstable.url = github:NixOS/nixpkgs/nixos-unstable;
    nix.url = github:NixOS/nix;
    home-manager.url = github:rycee/home-manager/release-21.11;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = github:NixOS/nixos-hardware;
  };

  # Taken from https://github.com/davidtwco/veritas/blob/master/flake.nix
  outputs = { self, ... }@inputs:
    with inputs.nixpkgs.lib;
    let
      forEachSystem = genAttrs [ "x86_64-linux" ];
      pkgsBySystem = forEachSystem (system:
        import inputs.nixpkgs {
          inherit system;
          config = import ./nixpkgs/config.nix;
          overlays = self.internal.overlays."${system}";
        }
      );

      mkNixOsConfiguration = name: { system, config }:
        nameValuePair name (nixosSystem {
          inherit system;
          modules = [
            ({ name, ... }: {
              # Set the hostname to the name of the configuration being applied (since the
              # configuration being applied is determined by the hostname).
              networking.hostName = name;
            })
            ({ inputs, ... }: {
              # Use the nixpkgs from the flake.
              nixpkgs = { pkgs = pkgsBySystem.${system}; };

              # For compatibility with nix-shell, nix-build, etc.
              environment.etc.nixpkgs.source = inputs.nixpkgs;
              nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];
            })
            ({ inputs, pkgs, ... }: {
              nix = {
                autoOptimiseStore = true;
                # Don't rely on the configuration to enable a flake-compatible version of Nix.
                package = pkgs.nixFlakes;
                extraOptions = "experimental-features = nix-command flakes";
                # Re-expose self, nixpkgs and unstable as flakes.
                registry = {
                  self.flake = inputs.self;
                  nixpkgs = {
                    from = { id = "nixpkgs"; type = "indirect"; };
                    flake = inputs.nixpkgs;
                  };
                  unstable = {
                    from = { id = "unstable"; type = "indirect"; };
                    flake = inputs.unstable;
                  };
                };
              };
            })
            (import config)
          ];
          specialArgs = { inherit name inputs; };
        });

      mkHomeManagerConfiguration = name: { system, config }:
        nameValuePair name ({ ... }: {
          imports = [
            (import config)
          ];

          # For compatibility with nix-shell, nix-build, etc.
          home.file.".nixpkgs".source = inputs.nixpkgs;
          systemd.user.sessionVariables."NIX_PATH" =
            mkForce "nixpkgs=$HOME/.nixpkgs\${NIX_PATH:+:}$NIX_PATH";

          # Use the same Nix configuration throughout the system.
          xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs/config.nix;

          # Re-expose self, nixpkgs and unsable as flakes. For use in nix-search, for example
          xdg.configFile."nix/registry.json".text = builtins.toJSON {
            version = 2;
            flakes =
              let
                toInput = input:
                  {
                    type = "path";
                    path = input.outPath;
                  } // (
                    filterAttrs
                      (n: _: n == "lastModified" || n == "rev" || n == "revCount" || n == "narHash")
                      input
                  );
              in
              [
                {
                  from = { id = "self"; type = "indirect"; };
                  to = toInput inputs.self;
                }
                {
                  from = { id = "nixpkgs"; type = "indirect"; };
                  to = toInput inputs.nixpkgs;
                }
                {
                  from = { id = "unstable"; type = "indirect"; };
                  to = toInput inputs.unstable;
                }
              ];
          };
        });

      mkHomeManagerHostConfiguration = name: { system }: # The original template is much more flexible here
        nameValuePair name (inputs.home-manager.lib.homeManagerConfiguration {
          inherit system;
          configuration = { ... }: {
            imports = [ self.internal.homeManagerConfigurations."${name}" ];
            nixpkgs = {
              config = import ./nixpkgs/config.nix;
            };
            # home.packages = [inputs.nix.defaultPackage.${system}];
          };
          homeDirectory = "/home/sgraf";
          pkgs = pkgsBySystem."${system}";
          username = "sgraf";
        });

    in
    {
      # `internal` isn't a known output attribute for flakes. It is used here to contain
      # anything that isn't meant to be re-usable.
      internal = {
        # Attribute set of hostnames to home-manager modules with the entire configuration for
        # that host - consumed by the home-manager NixOS module for that host (if it exists)
        # or by `mkHomeManagerHostConfiguration` for home-manager-only hosts.
        homeManagerConfigurations = mapAttrs' mkHomeManagerConfiguration {
          nixos-lt = { system = "x86_64-linux"; config = ./nixpkgs/private.nix; };

          i44pc6 = { system = "x86_64-linux"; config = ./nixpkgs/work.nix; };

          pengwin = { system = "x86_64-linux"; config = ./nixpkgs/pengwin.nix; };
        };

        # Overlays consumed by the home-manager/NixOS configuration.
        overlays = forEachSystem (system: [
          # (self.overlay."${system}")
          (import ./nixpkgs/overlays/kak-git-mode.nix)
          (import ./nixpkgs/overlays/kak-lsp.nix)
          # (import ./nixpkgs/overlays/kak-tabs.nix)
          (import ./nixpkgs/overlays/nofib-analyse.nix)
        ]);
      };

      homeManagerHostConfigurations = mapAttrs' mkHomeManagerHostConfiguration {
        i44pc6 = { system = "x86_64-linux"; };
        pengwin = { system = "x86_64-linux"; };
      };

      # Attribute set of hostnames to evaluated NixOS configurations. Consumed by `nixos-rebuild`
      # on those hosts.
      nixosConfigurations = mapAttrs' mkNixOsConfiguration {
        nixos-lt = { system = "x86_64-linux"; config = ./nixos/nixos-lt.nix; };
      };

      # Expose an overlay which provides the packages defined by this repository.
      #
      # Overlays are used more widely in this repository, but often for modifying upstream packages
      # or making third-party packages easier to access - it doesn't make sense to share those,
      # so they in the flake output `internal.overlays`.
      #
      # These are meant to be consumed by other projects that might import this flake.
      # overlay = forEachSystem (system: _: _: self.packages."${system}");
    };
}
