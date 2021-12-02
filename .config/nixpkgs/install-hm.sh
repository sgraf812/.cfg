#! /bin/sh

REL=$(cat "$(dirname $0)/release")

# Install home-manager so that this config is picked up
sudo mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER

# https://github.com/nix-community/home-manager/issues/1479#issuecomment-711632098
nix-shell https://github.com/rycee/home-manager/archive/release-$REL.tar.gz -A install
nix-channel --add https://github.com/nix-community/home-manager/archive/release-$REL.tar.gz home-manager
nix-channel --update

home-manager switch && . ~/.zshrc
