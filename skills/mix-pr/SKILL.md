---
name: mix-pr
description: Ship work as pull requests in one run, with no approval step - branch, commit, push, and open the PR (one per repo touched; single, per-story, or stacked story PRs), then report each PR's link, title, and body. Also the single owner of branch, commit, and PR naming. Use when the user runs /mix-pr or asks to open a PR, ship, or push, and whenever another mix-* skill needs a branch, a commit, or a name.
argument-hint: "[branch | commit] [feature dir] [story] [repo]"
---

# Branches & PRs

The single owner of naming and delivery conventions. Every branch, commit, and PR name comes from
the config, never from habit.

**Context**: call the Skill tool with `mix-scope` for the project config (its repos, `git` and
`tracker` blocks). Nothing configured → `spec/[NNN]-[slug]`, strategy `single`, PR title
`[type]: [title]`, conventional commits.

## Who triggers what

- **`/mix-pr` (no action), or the user asking in their own words to open a PR, ship, or push**:
  that request is the approval. Run **ship** end to end with no confirmation step, then show the
  result. Changes to title or body come afterwards, when the user asks in the chat.
- **`branch` / `commit` requested by another skill**: local only; the calling skill owns the
  user's approval. Push and PR never start from another skill's request: answer it with the
  command to run (`/mix-pr`) and stop.

## Ship (default)

Per repo touched by the current work (repos with no changes get nothing):

1. **Branch**: on the base branch → resolve the name and create it (`branch`). On any other
   branch → keep it.
2. **Commit**: uncommitted changes → `commit` them. Files that clearly do not belong to the work
   (secrets such as `.env`, build output, unrelated strays) stay unstaged and go in the report.
3. **Push**: `git -C <repo> push -u origin <branch>`.
4. **PR**: open it (`pr`). A PR already open for the branch → update its title and body instead
   of opening a second one.
5. **Report**, per PR:

   ```text
   <repo> → <PR URL>
   Title: <title>
   <body, verbatim>
   ```

   Then list files left unstaged, and close with: "Want a different title or description? Tell
   me what to change and I update the PR."

Values that would otherwise be asked (`[ticket]`, unknown variables) are inferred from the
branch name, spec, or commits; ask only when no source has them, in one question, before step 1.
`[type]` is inferred without confirmation.

Stop and report only on: a failed push (rejected, no remote), no changes and no commits ahead of
the base, or a merge conflict. Never force-push.

**Edits after the report**: on request, `gh pr edit <n> --title ... --body-file ...` (or
`glab mr update`); show the new title and body.

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
| `[type]` | inferred (feat, fix, chore, refactor, docs, test, perf) |
| `[ticket]` | from the branch, spec, or commits, else asked; validated against `tracker.key_example` |
| any other | inferred when a source has it, else asked |

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

**branch**: resolve the name, then in each repo touched `git -C <repo> switch -c <name> <base>`.
If it exists, switch to it. Never switch over uncommitted work that belongs to another branch.

**commit**: per repo, stage only the files the current task or story touched (check
`git status` for strays; never stage everything blindly). Message per `commit_style`:
`conventional` → `<type>(<scope>): <summary>`; `ticket-prefix` → `<ticket> <summary>`; `free` →
a plain summary. Imperative mood, under 72 characters; a body only for a non-obvious why.

**push**: `git -C <repo> push -u origin <branch>` for each repo touched.

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
(draft for macro PRs); GitLab → `glab mr create`; other hosts (Bitbucket, etc.) without a CLI →
print the title and body and the create-PR URL for the remote. Record each PR URL in the story's Delivery line, and append it under `prs`
in `state.yml` in the feature folder, next to `spec.md`:

```yaml
prs:
  - https://github.com/acme/web/pull/5
```

File missing → create it with only `prs`. File present → add the URL to the list and keep every
other key (such as `status` and `next_step`) and comment. A PR that was only printed or planned
(no git, no `gh`/`glab`) writes nothing there.

**Done when** every repo touched has its PR open, the Delivery line and `prs` list them, and the
report shows each PR's link, title, and body.
