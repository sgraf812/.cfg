{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
    unstable.url = github:NixOS/nixpkgs/nixos-unstable;
    nix.url = github:NixOS/nix;
    home-manager.url = github:rycee/home-manager/release-22.05;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = github:NixOS/nixos-hardware;
    nofib.url = git+https://gitlab.haskell.org/ghc/nofib?ref=wip/input-utf8;
    nofib.flake = false;
  };

  # Taken from https://github.com/davidtwco/veritas/blob/master/flake.nix
  outputs = { self, ... }@inputs:
    with inputs.nixpkgs.lib;
    let
      username = "sgraf";
      forEachSystem = genAttrs [ "x86_64-linux" ];
      pkgsBySystem = forEachSystem (system:
        import inputs.nixpkgs {
          inherit system;
          config = import ./nixpkgs/config.nix;
          # Overlays consumed by the home-manager/NixOS configuration.
          overlays = [
            (import ./nixpkgs/overlays/kak-git-mode.nix)
            (import ./nixpkgs/overlays/kak-lsp.nix)
            # (import ./nixpkgs/overlays/kak-tabs.nix)
            (import ./nixpkgs/overlays/nofib-analyse.nix inputs.nofib)
          ];
        }
      );

      unstableBySystem = forEachSystem (system:
        import inputs.unstable {
          inherit system;
          config = import ./nixpkgs/config.nix;
        }
      );

      # mkHomeManagerConfiguration could just be
      #    nameValuePair hostname config
      # But the nix/registry.json settings need access to inputs.
      # Since the other stuff belongs with those settings, it makes
      # sense to have this function. Although we could have solved this through passing inputs as extraSpecialArgs.
      mkHomeManagerConfiguration = hostname: { system, config }:
        nameValuePair hostname ({ ... }: {
          imports = [
            (import config)
          ];

          # For compatibility with nix-shell, nix-build, etc.
          home.file.".nixpkgs".source = inputs.nixpkgs;
          systemd.user.sessionVariables."NIX_PATH" =
            mkForce "nixpkgs=$HOME/.nixpkgs\${NIX_PATH:+:}$NIX_PATH";

          # Use the same Nix configuration throughout the system.
          xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs/config.nix;
          xdg.configFile."nix/nix.conf".source = ./nix/nix.conf;

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

      mkNixOsConfiguration = hostname: { system, config }:
        nameValuePair hostname (nixosSystem {
          inherit system;
          modules = [
            ({ hostname, ... }: {
              # Set the hostname to the name of the configuration being applied (since the
              # configuration being applied is determined by the hostname).
              networking.hostName = hostname;
            })
            ({ inputs, ... }: {
              # Use the nixpkgs from the flake.
              nixpkgs.pkgs = pkgsBySystem.${system};

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
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.${username} = homeManagerConfigurations."${hostname}";
              home-manager.extraSpecialArgs = {
                inherit hostname inputs;
                unstable = unstableBySystem."${system}";
              };
            }
            (import config)
          ];
          specialArgs = {
            inherit hostname inputs;
            unstable = unstableBySystem."${system}";
          };
        });

      mkHomeManagerHostConfiguration = hostname: { system, username }: # The original template is much more flexible here
        # home-manager switch --flake tries `<flake-uri>#homeConfigurations."${username}@${hostname}"`
        nameValuePair "${username}@${hostname}" (inputs.home-manager.lib.homeManagerConfiguration {
          inherit system;
          configuration = { ... }: {
            imports = [ homeManagerConfigurations."${hostname}" ];
            nixpkgs.config = import ./nixpkgs/config.nix;
            home.packages = with pkgsBySystem."${system}"; [
              nixFlakes
              # home-manager # Don't put home-mananger here, as that clashes with program.home-manager.enable
            ];
          };
          homeDirectory = "/home/${username}";
          pkgs = pkgsBySystem."${system}";
          username = "${username}";
          extraSpecialArgs = {
            inherit hostname inputs;
            unstable = unstableBySystem."${system}";
          };
        });

      # Attribute set of hostnames to home-manager modules with the entire configuration for
      # that host - consumed by the home-manager NixOS module for that host (if it exists)
      # or by `mkHomeManagerHostConfiguration` for home-manager-only hosts.
      homeManagerConfigurations = mapAttrs' mkHomeManagerConfiguration {
        nixos-lt = { system = "x86_64-linux"; config = ./home/private.nix; };
        i44pc6 = { system = "x86_64-linux"; config = ./home/work.nix; };
        Sebastian-PC = { system = "x86_64-linux"; config = ./home/pengwin.nix; };
      };

      homeManagerHostConfigurations = mapAttrs' mkHomeManagerHostConfiguration {
        i44pc6       = { system = "x86_64-linux"; username = "sgraf-local"; };
        Sebastian-PC = { system = "x86_64-linux"; username = "sgraf"; };
      };

      # Attribute set of hostnames to evaluated NixOS configurations. Consumed by `nixos-rebuild`
      # on those hosts.
      nixosHostConfigurations = mapAttrs' mkNixOsConfiguration {
        nixos-lt = { system = "x86_64-linux"; config = ./nixos/nixos-lt.nix; };
      };

    in
    {
      homeConfigurations = homeManagerHostConfigurations;
      nixosConfigurations = nixosHostConfigurations;
    };
}
