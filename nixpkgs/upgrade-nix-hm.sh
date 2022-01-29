#! /usr/bin/env bash

echo "Updating <nixpkgs> and <home-manager> channels to version specified in $(dirname $0)/release..."

REL=$(cat "$(dirname $0)/release")

# home-manager needs the stable branch to be called "nixpkgs".
nix-channel --add https://nixos.org/channels/nixos-$REL nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/release-$REL.tar.gz home-manager
nix-channel --update
. ~/.nix-profile/etc/profile.d/nix.sh

# https://github.com/nix-community/home-manager/issues/1479#issuecomment-711632098
# nix-shell https://github.com/nix-community/home-manager/archive/release-$REL.tar.gz -A install && . ~/.zshrc
home-manager switch && . ~/.zshrc
