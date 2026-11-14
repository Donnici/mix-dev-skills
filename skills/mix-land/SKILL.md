---
name: mix-land
description: "Get open PRs merge-ready across the project's repos: list them with CI, conflicts, and unresolved review comments; classify each CI failure (this PR, inherited from base, flaky, infra); reproduce before fixing; draft reviewer replies; and give the merge order. Use when the user asks to get PRs green, fix CI, resolve review comments, update a branch with main, or asks what is left to merge."
argument-hint: "[PR number | repo | all]"
---

# Land

Take the user's open PRs from "opened" to "ready to merge": checks green, conflicts resolved,
review comments answered, and a merge order across repos. The user keeps the merge.

**Context**: call the Skill tool with `mix-scope` for the project: its repos, the config (`git`
block, including `pr_reply_tone`), and each repo's architecture doc (**Commands** and **Local
environment**). Needs git and `gh` (or `glab`); without them, say so and stop.

## Writes need a yes

Local edits and local commits follow the user's request. Anything that reaches the remote
(push, PR edits, replies to reviewers, re-running checks) happens only when the user asked for
it in their own words, and replies are shown before posting. Never merge, never force-push.

## 1. Inventory

Run the `mix-pr` preflight (auth, rate limit) once. Then, for each repo in scope (the argument,
else all repos):

```bash
gh pr list -R <owner/repo> --author @me --state open --json number,title,headRefName,baseRefName,isDraft,mergeable,reviewDecision,statusCheckRollup,url
```

For each PR, also read its unresolved review threads (`gh pr view <n> --comments`, or the
GraphQL `reviewThreads` field).

**Done when** a table lists every open PR: repo, number, title, checks (pass / fail / pending),
mergeable, review state, unresolved threads.

## 2. Classify each failing check

Fetch the failing job's log (`gh run view <run> --log-failed`) and put each failure in one class,
with the evidence line:

- **this PR**: the failure points at code or tests the PR changed.
- **inherited**: the same check fails on the base branch's latest run, or the failure comes
  from a dependency not merged yet (a client generated from an unmerged upstream branch).
- **flaky**: it passed on a re-run of the same commit, or the log shows a timeout or race
  unrelated to the diff.
- **infra**: runner, quota, secret, or network error.

**Done when** each failing check has a class and an evidence line.

## 3. Fix what this PR caused

For each **this PR** failure, in the PR's worktree or branch (never over uncommitted work of
another branch: stop and ask):

1. Bring up the repo's **Local environment** and reproduce the failure with the CI command.
   No local reproduction after a real attempt → call the Skill tool with `mix-diagnose`.
2. Before editing, name the invariant the failing test or rule protects (a valid config
   combination, a lock order, a lint rule) and check the fix keeps it.
3. Fix, then run the repo's formatter, whole-package lint and typecheck, and the affected tests,
   exactly as its **Commands** table gives them.
4. Commit locally with a `mix-pr` commit message.

**Inherited** failures are not patched in this PR: record the root cause and which PR or branch
must land first. **Flaky** → re-run only when the user asked for remote actions. **Infra** →
report.

**Done when** every **this PR** failure passes locally, or is reported with what blocked it.

## 4. Conflicts and base updates

When the PR conflicts with its base, or the user asked to update it: first check whether other
open PRs touch the same files (`gh pr diff` of the siblings) and say what merging them first
would change. Then merge the base into the branch (a pushed branch is never rebased: that needs
a force-push), resolve conflicts keeping both intents, and re-run the gates.

**Done when** the branch has no conflict with its base and the gates pass.

## 5. Review comments

For each unresolved thread: fix it when the comment asks for a change, else prepare an answer.
Draft one reply per thread in the config's `git.pr_reply_tone` (default: short and direct),
saying what changed and where, or why not. Show every draft; post only the ones the user
approves.

**Done when** each thread has a fix and a draft reply, or a draft explaining why not.

## 6. Push and merge order

Pushing is `mix-pr`'s: when the user asked to push or update the PRs, call the Skill tool with
`mix-pr` for each branch with new commits; otherwise name `/mix-pr` as the next step.

Merge order across repos: provider before consumer (the system architecture doc's order of
change), blockers named in step 2's **inherited** findings first, stacked PRs bottom-up.

**Done when** the report gives a merge order covering every open PR.

## 7. Report

```markdown
## Land: <scope>

| Repo | PR | Checks | Class of failures | Actions taken | Blocked by | Ready |
|------|----|--------|-------------------|---------------|------------|-------|

**Merge order**: 1. <repo#n> → 2. … (why)
**Replies**: <n posted · n awaiting approval>
**Next step**: <`/mix-pr`, a PR to land first, or "ready to merge">
```

If the same failure class keeps recurring (a formatter, a lint rule, a local setup step),
suggest `/mix-retro` to turn it into a rule or check.
