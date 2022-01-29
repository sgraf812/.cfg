self: super:

{
  unstable = import (builtins.fetchGit (import ../unstable.nix)) { overlays = []; };
}
