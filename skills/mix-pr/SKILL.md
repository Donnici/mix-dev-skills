---
name: mix-pr
description: Name and create branches and commits following the project's patterns, and, only when the user explicitly asks, push and open pull requests (single PR, per-story PRs, or stacked story PRs, one per repo touched). Use when starting a feature or story branch, committing finished work, when the user asks to push or open a PR, and whenever another mix-* skill needs a branch or PR name.
argument-hint: "[branch | commit | push | pr] [feature dir] [story] [repo]"
---

# Branches & PRs

The single owner of naming and delivery conventions. Every branch, commit, and PR name comes from
the config, never from habit.

**Context**: call the Skill tool with `mix-scope` for the project config (its repos, `git` and
`tracker` blocks). Nothing configured → `spec/[NNN]-[slug]`, strategy `single`, PR title
`[type]: [title]`, conventional commits.

## Nothing leaves the machine without the user

- **branch** and **commit** are local. Another skill may request them; each still shows the name
  or message and waits for "yes" before running.
- **push** and **pr** run only when the user asked for them in this conversation, in their own
  words ("push", "open the PR", `/mix-pr pr`). A request relayed by another skill is never
  enough: answer it with the exact commands and PR text the user can approve, and stop.
- Before any push or PR, show per repo: remote, branch, target base, title, and body. Run only
  after the user confirms that exact plan. One confirmation covers the plan shown, nothing else.

## Git is optional

- `git.enabled: false`, or a repo is not a git repo → touch no git there. Write the planned
  branch names, commit messages, and PR titles/bodies to `<feature>/delivery.md` for the user to
  apply by hand, and continue the calling flow.
- Git but no `gh` / `glab` (or not authenticated) → for PRs, print the title and body ready to
  paste, and the compare URL when the remote is known.

## Multi-repo

A feature touches one or more repos. Branches and PRs are per repo: the same branch name in every
repo the feature (or story) touches, one PR per repo. Each PR body links its sibling PRs and says
the merge order (provider before consumer: api → bff → web, per the system architecture doc's
order of change). Repos the feature doesn't touch get no branch.

## Resolving a name

Patterns are fixed text plus `[variables]`:

| Variable | Source |
|----------|--------|
| `[NNN]` | feature folder number |
| `[slug]` | feature short name |
| `[story]` | story id + short name, e.g. `us1-login` |
| `[title]` | feature or story title, sentence case |
| `[type]` | inferred (feat, fix, chore, refactor, docs, test, perf), then confirmed |
| `[ticket]` | asked; validated against `tracker.key_example` |
| any other | asked |

Values already recorded in the spec's **Delivery** line or the story's Delivery line in
`tasks.md` are reused, never asked twice. Every asked value is written back there.

## Delivery strategies

From `git.strategy`, unless overridden for this feature in the spec's Delivery line:

- **single**: one branch from the base branch using `branch_pattern`; one PR per repo at the end.
- **per-story**: per story, a branch from the base using `story_branch_pattern`; one PR per repo
  when the story is done. A story depending on an earlier one branches from that story's branch
  and says so in the PR body.
- **per-story-stacked**: a feature branch from the base using `branch_pattern` with a draft macro
  PR; story branches from the feature branch, each PR targeting it. The macro PR is marked ready
  when every story PR is merged into it.

## Actions

**branch**: resolve the name, confirm, then in each repo touched
`git -C <repo> switch -c <name> <base>`. If it exists, offer to switch to it instead.

**commit**: per repo, stage only the files the current task or story touched (check
`git status` for strays; never stage everything blindly). Message per `commit_style`:
`conventional` → `<type>(<scope>): <summary>`; `ticket-prefix` → `<ticket> <summary>`; `free` →
a plain summary. Imperative mood, under 72 characters; a body only for a non-obvious why.

**push**: `git -C <repo> push -u origin <branch>` for each repo in the confirmed plan.

**pr**: title from `pr_title_pattern`; body from the repo's PR template when `pr_template: auto`
finds one, else:

```markdown
## What
<one to three sentences: the behaviour this PR delivers>

## Why
<the problem, linking the ticket(s)>

## Scope
- Story: <US# title> (<ticket>) · Spec: <spec link, omitted when the spec lives outside the repo>
- Related PRs: <sibling PRs in other repos, with merge order> · Part of: <macro PR, if stacked>

## How to verify
- [ ] <acceptance scenario as a check>

## Notes for reviewers
<decisions or trade-offs a reviewer would otherwise ask about; omit when none>
```

Keep it short; reviewers read the diff. `gh pr create --base <base> --title ... --body-file ...`
(draft for macro PRs). Record each PR URL in the story's Delivery line.
