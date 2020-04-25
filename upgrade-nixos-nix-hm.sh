#! /usr/bin/env bash

echo "Updating <nixos> sudo channel to version specified in $(dirname $0)/release..."

sudo nix-channel --add https://nixos.org/channels/nixos-$(cat "$(dirname $0)/release") nixos
sudo nix-channel --update
sudo nixos-rebuild switch

./upgrade-nix-hm.sh
