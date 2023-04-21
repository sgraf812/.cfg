mkdir -p ~/.config/nix/
echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf
sudo mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/$USER
sudo chown $USER -R /nix/var/nix/{profiles,gcroots}/per-user/$USER
nix run home-manager/master -- switch -b bak --flake $HOME/code/nix/config/
