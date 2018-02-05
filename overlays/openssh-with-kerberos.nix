self: super:

{
  openssh-with-kerberos = super.openssh.overrideAttrs (old: {
    withKerberos = true;
    withGssapiPatches = true;
  });
}
