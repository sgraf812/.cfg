---
name: handle-reviews
description: Handle the pending/unresolved review comments the user left on a GitHub PR — apply each as a code change or answer its question, verify the build and tests, then delete (or resolve) the threads and push. Use when the user says to handle/address/process their review comments, or "handle them, delete them, push".
---

# Handle my pending review comments

The user leaves feedback for themselves as review comments on their own PR, then asks to execute
them. Each comment is a directive: a concrete change, a suggestion block, or a question to decide.
Process them, verify, clean them up, and push.

## 1. Identify the PR

Default to the PR for the current branch. If the user named a PR number, use that instead.

```bash
gh pr view --json number,headRefName
OWNER=$(gh repo view --json owner --jq .owner.login)
REPO=$(gh repo view --json name --jq .name)
```

## 2. Fetch the open threads

Get unresolved threads with their GraphQL node id, the first comment's databaseId, author, path/line,
and body:

```bash
gh api graphql -f query='
{ repository(owner:"'"$OWNER"'", name:"'"$REPO"'") { pullRequest(number:PR) {
  reviewThreads(first:100) { nodes {
    id isResolved path line
    comments(first:1){ nodes { databaseId author{login} body } } } } } } }' \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[]
        | select(.isResolved==false)
        | {id, path, line, dbid:.comments.nodes[0].databaseId,
           author:.comments.nodes[0].author.login, body:.comments.nodes[0].body}'
```

Keep the threads authored by the user.

## 3. Handle each comment

Treat the body as an instruction, anchored at `path:line`:

- Concrete change → make it.
- ```suggestion``` block → apply it verbatim.
- A question ("is there a function to reuse?", "double-check X") → investigate against the current
  code, decide, and either change or record the answer. Verify hypotheses before acting; do not
  assume a memory or a comment still matches the code.

Group related comments; make minimal, in-context edits that read like the surrounding code.

## 4. Verify

Rebuild and run the relevant tests. Never report done without a clean build and passing tests. For
a formatter/pp or grammar change, also run a regression slice, since such changes ripple to golden
tests elsewhere.

## 5. Clean up the threads

The comments are the user's own working notes, not part of the record — delete them by default:

```bash
gh api -X DELETE repos/$OWNER/$REPO/pulls/comments/DBID
```

If the user asked to **resolve** instead of delete:

```bash
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -f id=THREAD_ID
```

If a standalone reply 422s with `user_id can only have one pending review per pull request`, the user
has an open draft review: do not submit or dismiss it. Delete/resolve the threads and put the
per-item reasoning in chat instead.

## 6. Commit and push

One commit per logical change (follow the repo's commit convention and the user's global CLAUDE.md
identity/footers). Split unrelated working-tree changes out of the commit rather than sweeping them
in with `git add -A`. Push to the PR branch.

## 7. Report

For each comment: what it asked and how it was handled (changed / answered / no-op with reason).
