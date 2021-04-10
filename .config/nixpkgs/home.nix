let 
  os = builtins.elemAt (builtins.match "(.*[[:space:]])?NAME\=\"?([A-z]*).*" (builtins.readFile /etc/os-release)) 1;
in 
{
  imports = [ 
    (if os == "NixOS"
      then ./home/private.nix 
     else if os == "Pengwin"
      then ./home/pengwin.nix
     else
      ./home/work.nix)
  ];
}
