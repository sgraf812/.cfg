self: super:

{
  openssh = super.openssh.overrideAttrs (old: {
    withKerberos = true;
    withGssapiPatches = true;
  });
}
