self: super:

{
  libinput-gestures = super.libinput-gestures.overrideAttrs (old: {
    postFixup =
	  ''
		rm "$out/bin/libinput-gestures-setup"
		substituteInPlace "$out/share/applications/libinput-gestures.desktop" --replace "/usr" "$out"
		chmod +x "$out/share/applications/libinput-gestures.desktop"
		wrapProgram "$out/bin/libinput-gestures" --prefix PATH : "${self.lib.makeBinPath ([self.coreutils] ++ [])}"
	  '';
  });
}
