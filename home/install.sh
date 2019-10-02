#! /bin/bash

# (Re-)Install nix
sh <(curl https://nixos.org/nix/install) --daemon
nix-channel --add https://nixos.org/channels/nixos-$(cat "$(dirname $0)/release") nixos
nix-channel --update
. /etc/profile.d/nix.sh

# Install home-manager so that this config is picked up
$(dirname $0)/install-home-manager.sh
