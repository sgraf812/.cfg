self: super:

{
  nofib-analyse = with super.haskell.lib;
    lib.justStaticExecutables
      (lib.overrideCabal
        (lib.doJailbreak super.haskellPackages.nofib-analyse)
        {
          broken = false;
          src = (builtins.fetchGit {
            url = "https://gitlab.haskell.org/ghc/nofib";
            ref = "master";
          }) + "/nofib-analyse";
        });
}
