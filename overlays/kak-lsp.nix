self: super:

{
  kakounePlugins = super.kakounePlugins // {
    kak-lsp = super.stdenv.mkDerivation {
      pname = self.kak-lsp.pname + "-plugin";
      version = self.kak-lsp.version;
      phases = ["installPhase"];
      installPhase = ''
	mkdir -p $out/share/kak/autoload/plugins
	echo -e "eval %sh{${self.kak-lsp}/bin/kak-lsp --kakoune -s $kak_session}\nlsp-enable" > $out/share/kak/autoload/plugins/lsp
      '';
    };
  };
}
