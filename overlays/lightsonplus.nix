self: super:

{
  lightsonplus = super.stdenv.mkDerivation rec {
    pname = "lightsonplus";
    version = "0.1.1";

    src = super.fetchFromGitHub {
      owner = "sgraf812";
      repo = pname;
      rev = "0e63ae81cc00520425ba669d8b49afbf99e1d016";
      sha256 = "0y7csic4d8s7n85k1l6fw05kq6p2cgcs93g5xlqkv2hz5kll7f4x";
    };

    nativeBuildInputs = [ super.makeWrapper ];

    buildPhase = ''
      mkdir -p $out/bin
      cp lightson+ $out/bin/lightson+
      cp lightson+cmd $out/bin/lightson+cmd
    '';

    installPhase = let path = with self; [
        coreutils
        gawk
        gnugrep
        gnused
        procps
        xorg.xprop
        xorg.xset
        xorg.xvinfo
      ]; in ''
        wrapProgram $out/bin/lightson+ \
          --prefix PATH : ${super.stdenv.lib.makeBinPath path}
        wrapProgram $out/bin/lightson+cmd \
          --prefix PATH : ${super.stdenv.lib.makeBinPath path}
      '';

    meta = with self.stdenv.lib; {
      description = "Bash script managing screensaver and display power management (DPMS) on different conditions (fullscreen videos, specific applications, specific outputs).";
      homepage = "https://github.com/sgraf812/lightsonplus";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  };
}
