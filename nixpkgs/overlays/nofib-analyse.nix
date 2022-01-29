nofib-src: self: super:

{
  nofib-analyse =
    super.haskell.lib.justStaticExecutables
      (super.haskell.lib.overrideCabal
        (super.haskell.lib.doJailbreak super.haskellPackages.nofib-analyse)
        {
          broken = false;
          src = nofib-src + "/nofib-analyse";
        });
}
