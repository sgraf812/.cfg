#! /bin/sh

# Start nscd
sudo apt update
sudo apt install nscd
nscd

# (Re-)Install nix
curl https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh

# Install home-manager so that this config is picked up
mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
HM_PATH=https://github.com/rycee/home-manager/archive/master.tar.gz
nix-shell $HM_PATH -A install
