#! /bin/sh

# Install home-manager so that this config is picked up
sudo mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
nix-shell https://github.com/rycee/home-manager/archive/release-$(cat "$(dirname $0)/release").tar.gz -A install
# Note that we don't add a home-manager channel and instead specify the `path`
# variable in our home-manager config. Seems easier to maintain with our `release` file.
