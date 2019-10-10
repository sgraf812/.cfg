#! /bin/sh

# Install home-manager so that this config is picked up
sudo mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
nix-shell https://github.com/rycee/home-manager/archive/release-$(cat "$(dirname $0)/release").tar.gz -A install
