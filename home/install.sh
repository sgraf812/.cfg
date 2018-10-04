#! /bin/sh

# Start nscd
sudo apt update
sudo apt install nscd
nscd

# (Re-)Install nix
curl https://nixos.org/nix/install | sh
nix-channel --add https://nixos.org/channels/nixos-$(cat "$(dirname $0)/release") nixos
nix-channel --update
. ~/.nix-profile/etc/profile.d/nix.sh

# Install home-manager so that this config is picked up
$(dirname $0)/install-home-manager.sh
