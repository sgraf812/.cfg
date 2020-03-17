self: super:

{
  unstable = import (builtins.fetchTarball (import ../unstable.nix)) { overlays = []; };
}
