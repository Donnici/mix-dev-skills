---
name: mix-housekeep
description: "Clean up after merged work across the project's repos: remove worktrees and local branches whose PRs are merged or closed, list branches not pushed yet, and bring the specs' state.yml and the project index in line with each PR's real status. Use when the user asks to clean worktrees or branches, prune merged work, check what is still open, or sync the specs with the PRs."
argument-hint: "[repo | all] [--dry-run]"
---

# Housekeep

Keep the machine and the specs honest: no worktree or branch for work that already landed, no
unpushed work forgotten, and every spec's recorded PRs matching their real state.

**Context**: call the Skill tool with `mix-scope` for the project: its repos, the specs folder,
the project's `index.md` when the hub keeps one, and the hub's conventions. Repos that are not
git repos are skipped and named once. Without `gh`/`glab`, PR states are unknown: list
worktrees and branches only, and remove nothing.

## Hard rule: nothing with work in it is removed

A worktree with uncommitted or untracked changes, or a branch with commits on no remote and no
merged PR, is never removed. Removal uses `git worktree remove` (without `--force`) and
`git branch -d` (never `-D`). Nothing is pushed here; unpushed branches are listed for `/mix-pr`.

## 1. Inventory

Per repo, run:

```bash
git -C <repo> fetch --prune
git -C <repo> worktree list --porcelain
git -C <repo> for-each-ref refs/heads --format='%(refname:short) %(upstream:short) %(upstream:track)'
gh pr list -R <owner/repo> --head <branch> --state all --json number,state,url,mergedAt   # per branch
```

**Done when** a table lists, per repo: branch, worktree path (if any), dirty (yes/no), ahead of
remote (n), PR (number and state: open, merged, closed, none).

## 2. Plan

Classify each row:

- **remove**: PR merged or closed, worktree clean, nothing unpushed → remove worktree, then
  branch.
- **keep, open**: PR open.
- **keep, push first**: commits not on the remote → name `/mix-pr`.
- **keep, dirty**: uncommitted changes → name the files.
- **keep, base**: the base branch and the branch checked out in the main worktree.

Show the plan. With `--dry-run`, stop here. Otherwise ask once: "Remove the N rows marked
remove?".

**Done when** the user answered, or `--dry-run` printed the plan.

## 3. Clean

For each approved row: `git -C <repo> worktree remove <path>`, then `git -C <repo> branch -d
<branch>`. A command that refuses (unmerged by git's view after a squash merge) → `-d` stays
refused; list it with the PR URL for the user to delete by hand. Finish with
`git -C <repo> worktree prune`.

**Done when** every approved row is removed or listed with the refusal message.

## 4. Sync the specs

For each spec in the project's `specs/` whose `state.yml` lists `prs`, compare with the states
from step 1:

- Every PR merged and `status: Implemented` → nothing to change.
- A PR merged while `status` says otherwise, or a listed PR closed without merge → report the
  mismatch with the PR URL; change `state.yml` only on the user's yes.
- The project's `index.md` (hub only, when it keeps one): a spec's line that no longer matches
  (says open, the PR is merged) is updated in the index's own style, following the hub's
  conventions (frontmatter `updated:` date).

**Done when** each mismatch is fixed with approval or listed in the report.

## 5. Report

```markdown
## Housekeep: <scope>

| Repo | Branch | Worktree | PR | Action |
|------|--------|----------|----|--------|

**Removed**: n worktrees · n branches
**To push** (`/mix-pr`): <repo:branch, n commits ahead>
**Specs synced**: <spec → change> | none
**Left for you**: <refused removals with reason>
```
