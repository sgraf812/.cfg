self: super:

{
  kakounePlugins = super.kakounePlugins // {
    kak-lsp = super.stdenv.mkDerivation {
      pname = self.kak-lsp.pname + "-plugin";
      version = self.kak-lsp.version;
      phases = ["installPhase"];
      installPhase = ''
	mkdir -p $out/share/kak/autoload/plugins
	echo -e 'eval %sh{${self.kak-lsp}/bin/kak-lsp --kakoune -s $kak_session}\nlsp-enable' > $out/share/kak/autoload/plugins/lsp.kak
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
  kak-lsp = super.kak-lsp;
#  kak-lsp = self.unstable.kak-lsp;
#  kak-lsp = super.kak-lsp.overrideAttrs (drv: rec {
#    version = "9.0.0-pre";
#    src = super.fetchFromGitHub {
#      owner = "kak-lsp";
#      repo = "kak-lsp";
#      rev = "354b46e3cf56f0da35b444941a701ca4c1135aa8";
#      sha256 = "00hwf7pgrhrk0d572xp4k82pama09ph7k8s63cg28ixsmzhpaiji";
#    };
#    cargoDeps = drv.cargoDeps.overrideAttrs (_: {
#      name = "${drv.pname}-${version}-vendor.tar.gz";
#      inherit src;
#      outputHash = "0av59ii201mzjzrhvc9nny6akxmmbfl0dfzxjhsqnbdgx03vxl5a";
#    });
#  });
}
