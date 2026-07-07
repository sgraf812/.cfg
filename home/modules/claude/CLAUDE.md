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

## Explanations

When precision matters, explain by unfolding the definitions and manipulating
the symbols, not by paraphrasing in prose; skip this only when an exact
statement already fits in one line. Introduce concrete detail only where it
exposes the mechanism, and follow the manipulation all the way to the claim it
establishes, stating that conclusion outright rather than gesturing at it. Keep
prose minimal; let the symbolic work carry the precision.

## Lean formalization

**Reuse before defining.** Before any new `def`, express the body in terms of
existing combinators and lemmas from the library. If you can't, you're missing
an abstraction: find it, or extract a reusable one. Don't inline by
pattern-matching on the underlying representation at the use site. If you've
added 3+ helpers in a session without citing existing infrastructure, stop and
audit; you're likely duplicating it.

**Think in APIs, not unfoldings.** Each definition gets a simp (and `grind`)
framework: the lemmas that characterize it. Prove against that API. Unfolding a
definition is a smell, justified only while building out the simp/`grind`
framework of the definition being unfolded. Elsewhere, reaching to unfold means
the API is incomplete; add the lemma instead.

**Scrap before patch.** When a definition or proof shape is wrong, delete and
restart. The "make Lean accept this" instinct produces worse code than the
"find the right abstraction" instinct. A working proof of the wrong shape is
worse than no proof; it ossifies the bad shape and breeds bridge lemmas to
compensate.

## Lean tooling

- Pre-build (`lake build`, `lake exe cache get`) before trusting lean-lsp-mcp
  goal queries; cold Mathlib elaboration is what makes it time out.
- On a lean-lsp-mcp timeout, pre-build or raise the timeout. Don't retry the
  same call.
- For tactic exploration, prefer REPL-backed `lean_multi_attempt` over repeated
  `lean_goal` round-trips.
