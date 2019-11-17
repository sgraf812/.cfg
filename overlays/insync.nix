self: super:

let
  deb-pkg = name: src: self.stdenv.mkDerivation {
    name = name;
    src = src;
    nativeBuildInputs = [ self.dpkg ];
    unpackPhase = ''
      mkdir -p $out
      dpkg --extract ${src} .
      cp -r usr/* $out
    '';
    installPhase = "true";
  };

  glibc-deb-pkg = deb-pkg "glibc-deb" (self.fetchurl {
    url = "http://ftp.debian.org/debian/pool/main/g/glibc/libc6_2.28-10_amd64.deb";
    sha256 = "6f703e27185f594f8633159d00180ea1df12d84f152261b6e88af75667195a79";
  });

  libz-deb-pkg = deb-pkg "libz-deb" (self.fetchurl {
    url = "http://ftp.debian.org/debian/pool/main/z/zlib/zlib1g_1.2.11.dfsg-1_amd64.deb";
    sha256 = "61bc9085aadd3007433ce6f560a08446a3d3ceb0b5e061db3fc62c42fbfe3eff";
  });

  insync-deb-pkg = pname: version: deb-pkg "insync-deb" (
    if self.stdenv.hostPlatform.system == "x86_64-linux" then
      self.fetchurl {
        url = "http://s.insynchq.com/builds/${pname}_${version}-buster_amd64.deb";
        sha256 = "f348fad2241dae11fe4d0af61398e40b900eab5d56f0e2d0cc75fc970c6b49eb";
      }
    else
    throw "${pname}-${version} is not supported on ${self.stdenv.hostPlatform.system}"
  );
in

{
  insync = self.buildFHSUserEnv rec {
    name = "insync-env";
    targetPkgs = pkgs: with pkgs; [
      glibc
      zlib
      libGL
      glib
      xorg.libxcb
      libxkbcommon
      qt5.qtvirtualkeyboard
      nss
      nspr
      alsaLib
      wayland
      pango

      glibc-deb-pkg
      (insync-deb-pkg "insync" "3.0.23.40579")
    ];
    runScript = "insync --help";
  };
}
