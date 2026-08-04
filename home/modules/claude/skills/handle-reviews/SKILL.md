---
name: handle-reviews
description: Handle the pending review comments the user wrote themselves on a GitHub PR. Apply each as a code change or answer its question, verify the build and tests, then delete (or resolve) those threads and push. Use when the user says to handle/address/process their review comments, or "handle them, delete them, push".
---

# Handle my pending review comments

The user leaves feedback for themselves as review comments on their own PR, then asks to execute
them. Each comment is a directive: a concrete change, a suggestion block, or a question to decide.
Process them, verify, clean them up, and push.

**Scope: pending comments the user wrote themselves.** Pending means the thread is still
unresolved. Comments by anyone else are out of scope for every step of this skill. Never action,
answer, reply to, resolve, or delete another person's review comment, even when it sits in the
file being edited and looks trivial to satisfy. Posting under the user's account speaks in their
voice; a reviewer reads it as the user answering them.

If someone else's comment looks worth acting on, say so in chat at the end and let the user
decide. Never post anything in reply.

## 1. Identify the PR

Default to the PR for the current branch. If the user named a PR number, use that instead.

```bash
gh pr view --json number,headRefName
OWNER=$(gh repo view --json owner --jq .owner.login)
REPO=$(gh repo view --json name --jq .name)
```

## 2. Fetch the user's own pending threads

Get unresolved threads whose first comment the user wrote, with the GraphQL node id, the comment's
databaseId, path/line, and body. Filter on the author in the query so nobody else's thread reaches
the work list:

```bash
ME=$(gh api user --jq .login)
gh api graphql -f query='
{ repository(owner:"'"$OWNER"'", name:"'"$REPO"'") { pullRequest(number:PR) {
  reviewThreads(first:100) { nodes {
    id isResolved path line
    comments(first:1){ nodes { databaseId author{login} body } } } } } } }' \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[]
        | select(.isResolved==false)
        | select(.comments.nodes[0].author.login=="'"$ME"'")
        | {id, path, line, dbid:.comments.nodes[0].databaseId,
           body:.comments.nodes[0].body}'
```

That result is the complete work list. Do not widen it, and do not re-run without the author
filter to "check what else is there". If the user explicitly asks about another person's comment,
that is a normal request handled outside this skill, and it still never includes replying to them.

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

Only the threads from step 2, which the user wrote themselves. They are working notes rather than
part of the record, so delete them by default:

```bash
gh api -X DELETE repos/$OWNER/$REPO/pulls/comments/DBID
```

If the user asked to **resolve** instead of delete:

```bash
gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -f id=THREAD_ID
```

The per-item reasoning goes in the chat report, never on the PR. Do not post replies, review
comments, or `gh pr review` in any form, and do not submit or dismiss a draft review the user has
open.

## 6. Commit and push

One commit per logical change (follow the repo's commit convention and the user's global CLAUDE.md
identity/footers). Split unrelated working-tree changes out of the commit rather than sweeping them
in with `git add -A`. Push to the PR branch.

## 7. Report

For each comment: what it asked and how it was handled (changed / answered / no-op with reason).
