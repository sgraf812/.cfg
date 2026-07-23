{ ... }:

# Personal, user-level Claude Code config loaded in every session.
# CLAUDE.md lives at ~/.claude/CLAUDE.md; skills under ~/.claude/skills/.
# Edit the sources in ./claude/.
{
  home.file.".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
  home.file.".claude/skills" = {
    source = ./claude/skills;
    recursive = true;
  };
}
