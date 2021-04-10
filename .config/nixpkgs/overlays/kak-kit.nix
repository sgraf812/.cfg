self: super:

{
  kakounePlugins = super.kakounePlugins // {
    kak-kit = super.stdenv.mkDerivation {
      pname = "kak-kit";
      version = "2020-12-26";
      src = super.fetchFromGitHub {
        owner = "chambln";
        repo = "kakoune-kit";
        rev = "634d4624fca795e845324d238eb6df5b2374aa2c";
        sha256 = "03pzpax0ak267hrrgv50nm8r8z3m16s60xrjgc5gyhv7g4br1pms";
      };
      phases = ["installPhase"];
      installPhase = ''
	mkdir -p $out/share/kak/autoload/plugins
	cp $src/rc/kit.kak $out/share/kak/autoload/plugins/kit.kak
      '';
      meta = with super.stdenv.lib; {
        description = "A Git porcelain inside Kakoune";
        homepage = "https://github.com/chambln/kakoune-kit";
        license = licenses.unlicense;
        maintainers = with maintainers; [ sgraf ];
        platforms = platforms.all;
      };
    };
  };
}
