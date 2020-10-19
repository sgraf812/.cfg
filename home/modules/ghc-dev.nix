{ pkgs, lib, ... }:

let 

  addSkipAndFreezeAliases = baseAliases: lib.fold (alias: a: a // {
    "${alias}s" = "${alias} --skip='//*.mk' --skip=stage1:lib:rts";
    "${alias}f" = "${alias}s --freeze1";
  }) baseAliases (builtins.attrNames baseAliases);

in

{
  imports = [ ];

  home.packages = with pkgs; [ ];

  programs.zsh = {
    shellAliases = ({
      cg = "valgrind --tool=cachegrind";
      head-hackage = ''
        cat << EOF >> cabal.project.local
        repository head.hackage.ghc.haskell.org
            url: https://ghc.gitlab.haskell.org/head.hackage/
            secure: True
            key-threshold: 3
            root-keys:
                f76d08be13e9a61a377a85e2fb63f4c5435d40f8feb3e12eb05905edb8cdea89
                7541f32a4ccca4f97aea3b22f5e593ba2c0267546016b992dfadcd2fe944e55d
                26021a13b401500c8eb2761ca95c61f2d625bfef951b939a8124ed12ecf07329
        EOF
      '';
    }) // addSkipAndFreezeAliases {
      hb = "hadrian/build -j$(($(ncpus) +1))";
      hbq = "hb --flavour=quick";
      hbv = "hb --flavour=validate --build-root=_validate";
      hbsv = "hb --flavour=slow-validate --build-root=_slow-validate";
      hbd2 = "hb --flavour=devel2 --build-root=_devel2";
      hbp = "hb --flavour=perf --build-root=_perf";
      hbt = "mkdir -p _ticky; [ -e _ticky/hadrian.settings ] || echo 'stage1.*.ghc.hs.opts += -ticky\\nstage1.ghc-bin.ghc.link.opts += -ticky' > _ticky/hadrian.settings; hb --flavour=perf --build-root=_ticky";
      hbd = "mkdir -p _dwarf; [ -e _dwarf/hadrian.settings ] || echo 'stage1.*.ghc.hs.opts += -g3\\nstage1.*.cabal.configure.opts += --disable-library-stripping --disable-executable-stripping' > _dwarf/hadrian.settings; hb --flavour=prof --build-root=_dwarf";
    };
  };
}
