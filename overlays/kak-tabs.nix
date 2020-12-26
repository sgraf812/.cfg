self: super:

{
  kakounePlugins = super.kakounePlugins // {
    kak-tabs = super.stdenv.mkDerivation {
      pname = "kak-tabs";
      version = "2020-12-26";
      src = super.fetchFromGitHub {
        owner = "enricozb";
        repo = "tabs.kak";
        rev = "96b6a37774e5f1ed8dff58b342fa2b92671905f1";
        sha256 = "0j589rzsh4xfdrj98zxs4gmfgmfs1x1f2yr29lwr94h52d38abr7";
      };
      phases = ["installPhase"];
      installPhase = ''
	mkdir -p $out/share/kak/autoload/plugins
	cp $src/rc/tabs.kak $out/share/kak/autoload/plugins/tabs.kak
      '';
      meta = with super.stdenv.lib; {
        description = "Kakoune buffers as tabs in the status line";
        homepage = "https://github.com/enricozb/tabs.kak";
        license = licenses.unlicense;
        maintainers = with maintainers; [ sgraf ];
        platforms = platforms.all;
      };
    };
  };
}
