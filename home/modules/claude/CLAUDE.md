# Personal memory

Managed by home-manager: to change this, edit
`home/modules/claude/CLAUDE.md` in `~/code/nix/config` and rebuild. The copy in
`~/.claude/` is a read-only symlink.

## Me

Sebastian Graf, Lean FRO researcher (`sg@lean-fro.org`, GitHub `sgraf812`).
GHC contributor; author of "Abstracting Denotational Interpreters". Not
Sebastian Ullrich (also Lean FRO).

I read at the `Expr`/elaborator level and have a deep PL-theory and compiler
background. Don't recap textbook material or oversimplify; state trade-offs
sharply, and show a plan before implementing.

## Git

- Commit identity when config is unset: `-c user.email=sgraf1337@gmail.com -c user.name="Sebastian Graf"`.
- No `Co-Authored-By: Claude` on commits; no "Generated with Claude Code" on PRs.

## Prose, comments, docstrings

**Never document a decision by contrasting it with a rejected alternative.**
Describe what exists, on its own terms.

- Say *what*, not *how*: no proof internals, no typeclass minutiae, no
  negatives ("does not...").
- No PR/issue refs, no "current vs future" framing. Write as if no prior
  discussion happened.
- Scope caveats and design justification go in the PR body, not a docstring.
- Rewrite a stale comment instead of appending to it; every comment has a
  maintenance cost.
- No `--` or `—` in prose (chat, comments, commits, PRs). Lean's `--` is fine.

Same instinct for plans, PR bodies, and slides: terse, no rejected
alternatives, no code sketches. Slide bullets are one-clause anchors.
