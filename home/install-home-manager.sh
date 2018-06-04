#! /bin/sh

# Install home-manager so that this config is picked up
sudo mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
HM_PATH=https://github.com/rycee/home-manager/archive/master.tar.gz
nix-shell $HM_PATH -A install
