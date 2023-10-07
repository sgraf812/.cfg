lhs2tex-src: self: super:

{
  lhs2tex = super.haskellPackages.lhs2tex.overrideAttrs (old:
        {
          src = lhs2tex-src + "/lhs2tex-1.24.tar.gz";
        });
}
