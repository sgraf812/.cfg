---
name: reclaim-disk
description: Report disk usage and reclaim space on a shared Lean development machine. Measure by user and by directory, classify each git worktree and elan toolchain as retained or disposable, salvage unpushed work, then delete. Use when the user says the disk is full, asks for a usage report, says their account retains too much, or asks what can be deleted.
---

# Reclaim disk space

The machine is shared and holds one XFS filesystem mounted `noquota`, so no per-user accounting
exists. Space goes to Lean build output: a lean4 worktree build costs about 6G, a mathlib `.lake`
about 4G to 12G, an elan toolchain about 3G. Twenty agent worktrees cost more than 100G.

Work in this order: measure, classify, salvage, delete, verify. Report numbers, not impressions.

## 1. Measure

```
df -h /
du -sh /home/* 2>/dev/null | sort -rh          # other homes need root
du -xsh /* 2>/dev/null | sort -rh | head -15
du -sh ~/* ~/.[!.]* 2>/dev/null | sort -rh | head -12
du -sh ~/code/lean/* 2>/dev/null | sort -rh | head -20
```

`df -h` is too coarse to show a 40G deletion against a 3.5T disk. Use `df -k / | tail -1 | awk
'{print $4}'` when you need the delta.

If other homes refuse to open, say so and name the users. Do not present a total that silently
omits them. `sudo du -sh /home/*` closes the gap, and sudo needs a password here, so hand that
command to the user.

Attribute `/tmp` by owner. Agent scratchpads under `/tmp/claude-*` reach tens of gigabytes.

## 2. Classify worktrees

Build one table. Never judge a worktree by size alone.

```
cd ~/code/lean/lean4 && git fetch --quiet origin
for n in .claude/worktrees/*/; do
  w=${n%/}; b=$(basename "$w"); [ -e "$w/.git" ] || continue
  t=$(du -sh "$w" | cut -f1); d=$(git -C "$w" log -1 --format=%cs)
  c=$(git -C "$w" status --porcelain | wc -l)
  br=$(git -C "$w" rev-parse --abbrev-ref HEAD); h=$(git -C "$w" rev-parse HEAD)
  if [ "$br" = HEAD ]; then p=detached
  elif git rev-parse --verify --quiet "refs/remotes/origin/$br" >/dev/null; then
    [ "$(git rev-parse refs/remotes/origin/$br)" = "$h" ] && p=pushed || p=ahead
  else p=NO-REMOTE; fi
  printf '%-26s %6s %-11s %5s %-10s\n' "$b" "$t" "$d" "$c" "$p"
done | sort -k3
```

Read the result as follows.

- `pushed` and no uncommitted files: delete the whole worktree. Origin holds every commit.
- `ahead` or `NO-REMOTE`: the commits exist only here. `git worktree remove` keeps the branch ref,
  so the commits survive in the repository. Say that plainly, and recommend a push.
- Uncommitted files: inspect them before you decide. Count alone misleads.
- `detached`: the commits lose their last reference. Tag the head before removal.

**Inspect uncommitted files, never trust the count.** A worktree reporting 4 modified files often
holds only the generated `tests/lake/tests/shake` fixture. One reporting 421 files held 420
regenerated `stage0/stdlib` C files plus one source edit. Both are disposable. A worktree with 10
edited files under `src/` is current work.

## 3. Decide "merged" by content, never by ancestry

**Every Lean PR is squashed on merge.** A squashed branch is never an ancestor of master, so
`git merge-base --is-ancestor` reports "unmerged" for work that landed weeks ago. Using it produces
false warnings and wastes the user's time.

Use two content tests instead.

```
# The squash keeps the PR title.
git log origin/master --oneline --since=<branch date> --grep="<subject keyword>" -i

# The identifiers the branch introduces.
git grep -l "<NewIdentifier>" origin/master -- src/
```

A tree diff against master proves nothing, because master moved ahead of the branch. The diff then
mixes "the branch lacks master's work" with "the branch holds unique work".

List the branch commits and account for each one. A branch often holds a `feat` commit and its own
`Revert`, which cancel, plus a merge commit with no payload.

## 4. Salvage before deleting

Deleting a worktree is recoverable, because the branch ref stays. Deleting a standalone repository
is not. Save first, into `~/code/lean/salvage/<name>/`:

```
git -C <repo> bundle create <salvage>/<branch>.bundle <branch>
git -C <repo> diff > <salvage>/uncommitted.patch
cp <repo>/<untracked files> <salvage>/
git -C <repo> format-patch -<n> -o <salvage> HEAD      # for a detached head
git -C ~/code/lean/lean4 tag salvage/<name> <sha>      # keeps commits reachable
```

Check a scratch file against its source before you keep it. A `prNNNNN-body.md` is usually the body
already posted on the PR, so `gh pr view NNNNN --json body -q .body` and `diff` settle it.

## 5. Check for live sessions

Never delete a scratchpad by modification time. Sessions stay open for weeks, and one held a
running benchmark that read its scratchpad.

```
{ for p in /proc/[0-9]*; do tr '\0' '\n' < "$p/cmdline" 2>/dev/null;
  readlink "$p/cwd" 2>/dev/null; done; } 2>/dev/null |
  grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | sort -u
```

Exclude every session id this prints. Also run `git -C ~/code/lean/lean4 worktree list | grep /tmp`,
because agent worktrees live in scratchpads.

## 6. Toolchains

Compare what is installed against what the checkouts pin.

```
find ~/code -maxdepth 4 -name lean-toolchain -not -path '*/.lake/*' -exec sh -c 'echo "$(cat "$1")"' _ {} \; | sort -u
du -sh ~/.elan/toolchains/* | sort -rh
elan toolchain uninstall <name>          # one argument per call
```

Removal is always recoverable, because `lake build` refetches a pinned toolchain. Some
`lean-toolchain` files carry no trailing newline, so a plain `cat` concatenates adjacent files. The
`sh -c 'echo ...'` form above adds the newline.

A toolchain far above 3G holds something extra. One reached 9.7G because a build wrote 6.8G into its
`lake` directory.

## 7. Caches

`~/.cache/lake` reaches 18G and refetches on demand. `~/.cache/mathlib` refetches with `lake exe
cache get`. `ccache` regrows to 5G within days, so cap it once with `ccache -M 2G` rather than
clearing it again.

## 8. Expect the permission classifier to refuse deletions

`rm -rf` and shell loops that delete are refused. These forms pass:

- One `git worktree remove --force <absolute path>` per Bash call. A loop or several commands in one
  call is refused. Parallel single-command calls work.
- `elan toolchain uninstall` inside a loop is accepted.
- `rmdir` for an empty directory is accepted.

When a deletion is refused, hand the user the exact command prefixed with `!` so it runs in their
session. A refusal of `rm -rf` on a repository with unpushed work is correct. Report it as such.

## 9. Report

State the before and after for the disk and for the home directory. Name what you kept and why.
Flag two things every time:

- Commits that exist only on this machine, with the branch name and sha.
- Growth since the last measurement, with its source. Worktree count times 6G explains most of it.

Measure the home directory again at the end. Other users and other sessions write to the same disk
while you work, so the free space can move by hundreds of gigabytes for reasons you did not cause.
Do not claim that movement as your result.
