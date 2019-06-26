#! /bin/sh

command -v lpass >/dev/null 2>&1 || { echo >&2 "Could not find \`lpass\`. Re-run in a \`nix-shell -p lastpass-cli\`.  Aborting."; exit 1; }

lpass show spotify --format="%fn=%fv" | grep -P '^(username|password)' > private/spotify.txt

lpass show 'Private id_rsa' --notes > private/id_rsa
lpass show 'Private id_rsa.pub' --notes > public/id_rsa.pub
