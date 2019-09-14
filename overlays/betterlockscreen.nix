self: super:

{
  betterlockscreen = super.betterlockscreen.overrideAttrs (old: {
    version = "master";

    src = super.fetchFromGitHub {
      owner = "pavanjadhaw";
      repo = "betterlockscreen";
      # fix scaling when Xft.dpi are set
      rev = "6c66db535fb6b83be74c2c84ede43352200f0968";
      sha256 = "1nzaxamzsm3annkcdy4xl2awn99qrribfnyid4v55m7lw92fc0a5";
    };
  });
}
