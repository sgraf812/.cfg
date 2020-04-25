#! /usr/bin/env bash

echo "Updating <nixos> channel and home-manager to version specified in $(dirname $0)/release..."

nix-channel --add https://nixos.org/channels/nixos-$(cat "$(dirname $0)/release") nixos
nix-channel --update
. /etc/profile.d/nix.sh

home-manager switch && ~/.zshrc
