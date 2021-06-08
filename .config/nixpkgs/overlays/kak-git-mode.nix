self: super:

{
  kakounePlugins = super.kakounePlugins // {
    kak-git-mode = super.stdenv.mkDerivation {
      pname = "kak-git-mode";
      version = "2020-11-02";
      src = super.fetchFromGitHub {
        owner = "jordan-yee";
        repo = "kakoune-git-mode";
        rev = "900733432370fe0e383ef99b0ecc83a82c9e67cd";
        sha256 = "117lqv64jcbkwjyhssxlrqn3hsm4qxbi5n1rlarx94lz9wnix3ik";
      };
      phases = ["installPhase"];
      installPhase = ''
	mkdir -p $out/share/kak/autoload/plugins
	cp $src/git-mode.kak $out/share/kak/autoload/plugins/git-mode.kak
      '';
      meta = with super.lib; {
        description = "Kakoune plugin providing improved git interaction";
        homepage = "https://github.com/jordan-yee/kakoune-git-mode";
        license = licenses.unlicense;
        maintainers = with maintainers; [ sgraf ];
        platforms = platforms.all;
      };
    };
  };
}
