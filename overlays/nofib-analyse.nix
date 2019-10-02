self: super:

{
  nofib-analyse =
    super.haskell.lib.justStaticExecutables
      (super.haskell.lib.overrideCabal
        (super.haskell.lib.doJailbreak super.haskellPackages.nofib-analyse)
        {
          broken = false;
          src = (builtins.fetchGit {
            url = "https://gitlab.haskell.org/ghc/nofib";
            ref = "wip/input-utf8";
          }) + "/nofib-analyse";
        });
}
