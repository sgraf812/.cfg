self: super:

{
  creduce-master = super.creduce.overrideAttrs (old: {
    name = "creduce-master";
    version = "2.8.0alpha";

    src = super.fetchFromGitHub {
      owner = "csmith-project";
      repo = "creduce";
      rev = "de21e365e218d36caac5e05a220a26dca68ea920";
      sha256 = "0dyfg1ibr9zybv0sqjasrjk90qsfz6rq2w9shjf58p8c6f5ss6js";
    };
  });
}
