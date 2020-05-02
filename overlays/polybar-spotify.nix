self: super:

let
  myPython = self.python.withPackages (ps: [ ps.dbus-python ]);
in

{
  polybar-spotify = self.stdenv.mkDerivation rec {
    pname = "polybar-spotify";
    version = "alpha";

    src = super.fetchFromGitHub {
      owner = "Jvanrhijn";
      repo = pname;
      rev = "50cfd6b6fd549cbbf36589454df65bcdbcb2473c";
      sha256 = "0ldzvdblhcjaf5xbj24czvlha5pcgalswz8735npdrylj9kc432x";
    };

    nativeBuildInputs = [ self.makeWrapper ];

    buildPhase = ''
      mkdir -p $out/bin

      # Strip the shebang
      sed -i '1 s/^#!.*//g' spotify_status.py
      # Add the new shebang (we don't do it with sed because of escaping the nix path)
      echo -e "#! ${myPython}/bin/python\n$(cat spotify_status.py)" > spotify_status.py

      chmod +x spotify_status.py
      cp spotify_status.py $out/bin/
    '';

    installPhase = let path = [ myPython ]; in ''
        wrapProgram $out/bin/spotify_status.py \
          --prefix PATH : ${self.stdenv.lib.makeBinPath path}
      '';

    meta = with self.stdenv.lib; {
      description = "Spotify artist and song module for Polybar";
      homepage = "https://github.com/Jvanrhijn/polybar-spotify";
      license = licenses.mit;
      platforms = platforms.all;
    };
  };
}
