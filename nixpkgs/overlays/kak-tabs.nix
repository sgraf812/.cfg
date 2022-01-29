self: super:

{
  kakounePlugins = super.kakounePlugins // {
    kak-tabs = super.stdenv.mkDerivation {
      pname = "kak-tabs";
      version = "2020-12-27";
      src = super.fetchFromGitHub {
        owner = "enricozb";
        repo = "tabs.kak";
        rev = "2775ab7a1fe3bb850c1de3bcc4111e3d4c24f5d4";
        sha256 = "1vyg1dgbrrsh4vj5lllp9lhslv6gip4v6vmym4lg5mnqmd82jji1";
      };
      phases = ["installPhase"];
      installPhase = ''
	mkdir -p $out/share/kak/autoload/plugins
	cp $src/rc/tabs.kak $out/share/kak/autoload/plugins/tabs.kak
      '';
      meta = with super.lib; {
        description = "Kakoune buffers as tabs in the status line";
        homepage = "https://github.com/enricozb/tabs.kak";
        license = licenses.unlicense;
        maintainers = with maintainers; [ sgraf ];
        platforms = platforms.all;
      };
    };
  };
}
