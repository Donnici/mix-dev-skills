---
name: mix-retro
description: "Turn what went wrong in a session or in PR review comments into lasting fixes: lint rules and CI checks for mechanical mistakes, constitution rules for judgement calls, architecture-doc updates for missing context."
disable-model-invocation: true
argument-hint: "[PR number(s) | 'session']"
---

# Retro

Improve the agent's **environment**, not the code, so the next run doesn't repeat the mistake.

## 1. Gather evidence

- **PR numbers** (needs `gh`) → read the human review comments:
  `gh api repos/{owner}/{repo}/pulls/<n>/comments` (inline) and `gh pr view <n> --comments`
  (conversation). Ignore bot comments and resolved nitpicks the author disagreed with.
- **Pasted comments** → review feedback the user pastes from any tool (Bitbucket, Azure DevOps,
  GitLab web).
- **Session** (default) → the current conversation: corrections the user made, things you got
  wrong, files you took long to find.
- Read the current constitution and architecture docs (paths from `mix-scope`), `CLAUDE.md` / `CLAUDE.local.md` / `AGENTS.md`,
  lint configs, and CI workflows, so you propose changes to what exists rather than duplicates.

## 2. Cluster

Group findings by root cause, not by file. Count occurrences; a pattern seen across several
comments or PRs ranks above a one-off. Discard one-offs that no rule would have prevented.

## 3. Pick the cheapest durable fix per cluster

In this order of preference:

1. **Automated check** for anything mechanical (a banned import, a file location, a syntax
   pattern, `console.log`, missing test file naming): a lint rule in the repo's existing linter,
   a pre-commit hook, or a CI job. Check the repo's existing scripts first: a check that exists
   but isn't wired up is the finding. A repo with no lint/typecheck/test in CI is itself a finding.
2. **Architecture doc** when the agent lacked context: a missing golden file, an unlisted library
   purpose, an undocumented pattern, an unresolved inconsistency.
3. **Constitution rule** for judgement calls a reviewer must apply (comment density, layering,
   what deserves a test). Phrased checkably, positively, with MUST/SHOULD.
4. **`CLAUDE.md` / `AGENTS.md`** only for a navigation pointer. Steering text there costs context
   on every turn; move rules out of it into the constitution or a check when you find them.

Also look for **no-ops**: rules already in the constitution or `CLAUDE.md` that change nothing
(the agent does it by default) or that keep being ignored (the wording is too weak, or it should
be a check). Propose deleting or sharpening them.

## 4. Propose

Present, ordered by impact: cluster → evidence (comment links or session excerpts, with counts) →
proposed fix → where it goes. Wait for the user to pick.

## 5. Apply

For constitution changes, call the Skill tool with `mix-constitution` with the approved rules.
Edit the architecture doc and lint/CI config directly. Report what changed and which future
mistakes each change should prevent.
