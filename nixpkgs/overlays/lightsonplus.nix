self: super:

{
  lightsonplus = super.stdenv.mkDerivation rec {
    pname = "lightsonplus";
    version = "0.1.1";

    src = super.fetchFromGitHub {
      owner = "sgraf812";
      repo = pname;
      rev = "44828a7c2e37dbac20f80341728cb73867469bbd";
      sha256 = "0cj9wcqhn3rlnclgl19d1bb9vjxx2xk0wrlhsbldc90p93qz9a2w";
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
          --prefix PATH : ${super.lib.makeBinPath path}
        wrapProgram $out/bin/lightson+cmd \
          --prefix PATH : ${super.lib.makeBinPath path}
      '';

    meta = with self.lib; {
      description = "Bash script managing screensaver and display power management (DPMS) on different conditions (fullscreen videos, specific applications, specific outputs).";
      homepage = "https://github.com/sgraf812/lightsonplus";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  };
}
