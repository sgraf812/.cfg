self: super:

{
  kakounePlugins = super.kakounePlugins // {
    kak-lsp = super.stdenv.mkDerivation {
      pname = self.kak-lsp.pname + "-plugin";
      version = self.kak-lsp.version;
      phases = ["installPhase"];
      installPhase = ''
	mkdir -p $out/share/kak/autoload/plugins
	echo -e 'eval %sh{${self.kak-lsp}/bin/kak-lsp --kakoune -s $kak_session}' > $out/share/kak/autoload/plugins/lsp.kak
      '';
      meta = with super.lib; {
        description = "Kakoune Language Server Protocol Client (Plugin)";
        homepage = "https://github.com/kak-lsp/kak-lsp";
        license = licenses.unlicense;
        maintainers = with maintainers; [ sgraf ];
        platforms = platforms.all;
      };
    };
  };
#  kak-lsp = super.kak-lsp;
#  kak-lsp = self.unstable.kak-lsp;
#  kak-lsp = super.kak-lsp.overrideAttrs (drv: rec {
#    version = "14.2.0";
#    src = super.fetchFromGitHub {
#      owner = "kak-lsp";
#      repo = "kak-lsp";
#      rev = "12bad0b5e4e6eb0dd567701fcd02a7247f6f3ef7";
#      sha256 = "sha256-U4eqIzvYzUfwprVpPHV/OFPKiBXK4/5z2p8kknX2iME=";
#    };
#    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
#      name = "${drv.pname}-${version}-vendor.tar.gz";
#      inherit src;
#      outputHash = "sha256-g63Kfi4xJZO/+fq6eK2iB1dUGoSGWIIRaJr8BWO/txM=";
#    });
#  });
}
