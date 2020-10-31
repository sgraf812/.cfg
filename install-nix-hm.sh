#! /usr/bin/env bash

# (Re-)Install nix
# sh <(curl https://nixos.org/nix/install)
# It's important to call the channel <nixpkgs>, otherwise e.g. home-manager won't pick it up
nix-channel --add https://nixos.org/channels/nixos-$(cat "$(dirname $0)/release") nixpkgs
nix-channel --update
. ~/.nix-profile/etc/profile.d/nix.sh

# Install home-manager so that this config is picked up
$(dirname $0)/install-hm.sh
