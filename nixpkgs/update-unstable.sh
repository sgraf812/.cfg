#! /usr/bin/env bash

cat > unstable.nix <<EOF
{
  name = "nixos-unstable-$(date --rfc-3339=date)";
  url = https://github.com/nixos/nixpkgs/;
  ref = "refs/heads/nixos-unstable";
  # Commit hash for nixos-unstable as of $(date --rfc-3339=date)
  # \$(git ls-remote https://github.com/nixos/nixpkgs nixos-unstable | cut -f)
  rev = "$(git ls-remote https://github.com/nixos/nixpkgs nixos-unstable | cut -f 1)";
}
EOF
