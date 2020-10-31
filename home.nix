let 
  os = builtins.elemAt (builtins.match ".*NAME\=([A-z]*).*" (builtins.readFile /etc/os-release)) 0;
in 
{
  imports = [ 
    (if os == "NixOS"
      then ./home/private.nix 
      else ./home/work.nix)
  ];
}
