{ lib, hostname, ... }:

# Personal, user-level Claude Code config loaded in every session.
# CLAUDE.md lives at ~/.claude/CLAUDE.md; skills under ~/.claude/skills/.
# Edit the sources in ./claude/. The build scope in CLAUDE.md is sized per
# host here. The laptop gets hard caps. The work box gets no cap: only a low
# CPU weight, so that a build yields under contention, and no swap, so that a
# runaway build is killed instead of stalling the machine.
let
  laptop = {
    props = "-p MemoryMax=6G -p MemorySwapMax=0 -p CPUQuota=800% -p CPUWeight=50";
    jobs = "8";
  };
  caps = {
    nixos-framework = laptop;
    chungus = { props = "-p MemorySwapMax=0 -p CPUWeight=50"; jobs = "96"; };
  }.${hostname} or laptop;
in
{
  home.file.".claude/CLAUDE.md".text = builtins.replaceStrings
    [ "@PROPS@" "@JOBS@" ] [ caps.props caps.jobs ]
    (builtins.readFile ./claude/CLAUDE.md);
  home.file.".claude/skills" = {
    source = ./claude/skills;
    recursive = true;
  };
}
