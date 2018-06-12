self: super:

{
  creduce-master = (super.creduce.override {
    inherit (super.llvmPackages_6) llvm clang-unwrapped;
  }).overrideAttrs (old: {
    version = "2.8.0alpha";

    buildInputs = old.buildInputs ++ [ super.perlPackages.SysCPU ];

    src = super.fetchFromGitHub {
      owner = "csmith-project";
      repo = "creduce";
      rev = "8e622ba74bc35c5a81299d3a34b9b14038d6a70";
      sha256 = "0dyfg1ibr9zybv0sqjasrjk90qsfz6rq2w9shjf58p8c6f5ss6js";
    };
  });
}
