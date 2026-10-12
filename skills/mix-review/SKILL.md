---
name: mix-review
description: Review a PR, branch, or working diff on three axes (Standards against the constitution and repo patterns, Spec against the feature spec, Tests for redundancy and coupling), verify each finding, then fix, append convergence tasks, or post PR comments. Use when the user asks to review code, a PR, or changes since a point, or when mix-implement self-reviews.
argument-hint: "[PR number | branch | ref] [--fix | --tasks | --comment]"
---

# Review

Review a diff on three separate axes, each in its own subagent so one axis can't mask another:

- **Standards**: does the code follow the constitution, the architecture doc, and the repo's
  existing patterns, and is it free of the AI smells in [AI-SMELLS.md](AI-SMELLS.md)?
- **Spec**: does it implement what the spec and tasks asked, no less and no more?
- **Tests**: does each test earn its place?

## 1. Pin the diff

- **PR number** → `gh pr view <n> --json baseRefName,headRefName,body,title` and
  `gh pr diff <n>`. Check out nothing; read files at the PR head with `gh` or `git show`.
- **Branch / ref** → `git diff <ref>...HEAD` (three-dot: against the merge-base) plus
  `git log <ref>..HEAD --oneline`.
- **Nothing given** → the merge-base with the configured base branch (else the default branch),
  plus uncommitted changes. When called by `mix-implement`, the diff of the delivery unit it names.
- **Multi-repo project** → resolve the target in each repo the feature touches (same branch name,
  or each repo's merge-base) and review them as one change. Findings cite `<repo>:<path>:<line>`.
- **No git** → the files the user names, else the `## Files touched` list in the feature's
  `tasks.md`, else the plan's **Files** list. Review those files whole; findings on code the
  feature didn't write are marked `pre-existing` and never blocking.

Confirm the target resolves and is non-empty before going further.

## 2. Gather sources

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos (one or
several) and the paths to the constitution, architecture docs, glossary, ADRs, and specs folder.

- **Standards**: the constitution, the architecture doc, `CODING_STANDARDS.md`, `CONTRIBUTING.md`,
  the glossary, ADRs in the touched area, and the lint/format configs (anything a tool already
  enforces is skipped).
- **Spec**: the feature folder whose spec **Delivery** line names this branch or ticket, issue
  links in the PR body or commits, or a path the user gave. For a story PR, scope the Spec axis
  to that story's requirements and scenarios. None found → ask; if there is none, the Spec axis
  is skipped and the report says so.

## 3. Run the three axes in parallel

Dispatch three read-only subagents together. Give each pointers, not pasted files: the diff
command, the source paths, and its brief. Each returns findings as
`file:line | severity | rule or spec line | evidence | fix`, under 400 words.

- **Standards brief**: "Read the constitution and architecture doc. For every changed file, open
  the closest existing file of the same kind (the golden file if listed) and compare. Report:
  (a) each violation of a documented rule, citing it; (b) each pattern deviation from the
  exemplar, naming the exemplar; (c) each code-level smell from AI-SMELLS.md, citing it. Search
  the repo before claiming something is reinvented, and name the existing helper or library.
  Repo rules override the smell list."
- **Spec brief**: "Map the diff to the spec's FRs, acceptance scenarios, and the tasks. Classify
  each gap as `missing`, `partial`, `contradicts` (behaviour conflicts with the spec or a
  constitution MUST), or `unrequested` (scope creep). Quote the spec line for each. When the plan
  has contracts, check both sides against them: every consumer call matches the provider's
  route, method, field names, types, optionality, error handling, and auth, and no side has a
  field or status the contract lacks."
- **Tests brief**: "Load the mix-testing skill's anti-patterns and pruning questions. For every
  test added or changed, report the ones that are redundant (name the test that already covers
  it), tautological, implementation-coupled, trivial, or copy-paste variants; and acceptance
  scenarios with no test at an agreed seam."

Without subagent support, run the three axes one after another, finishing each before starting
the next.

## 4. Verify

For every returned finding, open the cited lines yourself and confirm it is real. Drop false
positives, duplicates across axes (keep the one in the most specific axis), and anything a linter
or formatter enforces. Severity:

- **Blocking**: violates a constitution MUST; spec `missing` / `contradicts` on a P1 story;
  a bug.
- **Should fix**: pattern deviation, reinvented helper, redundant test, comment noise, scope creep.
- **Nit**: naming and minor style; at most five, the rest counted.

## 5. Report

```markdown
## Review: <target>

### Standards  (n blocking · n should-fix · n nits)
- **[blocking]** `src/x.ts:42` — <finding>. Rule: Constitution IV. Fix: <fix>.

### Spec  (n missing · n partial · n contradicts · n unrequested)
- **[missing]** FR-003 "<quoted line>" — <evidence>. Fix: <fix>.

### Tests  (n to delete · n to merge · n to rewrite · n gaps)
- `orders.test.ts:88` "creates order" — redundant with `orders.int.test.ts:20`. Delete.

**Worst per axis**: Standards: … · Spec: … · Tests: …
```

Keep the axes separate; don't rerank across them.

## 6. Act

With a flag, do that; otherwise ask which (several may apply):

- **`--fix`** (default when called by `mix-implement`): apply every blocking and should-fix
  finding, re-run the quality gates, and list what was not fixed and why.
- **`--tasks`**: append a `## Phase N: Convergence` section to the feature's `tasks.md` with one
  task per finding (`- [ ] T0XX <fix> per <FR-003 | Constitution IV | test> (<gap type>)`),
  blocking first, continuing the highest task ID. Existing tasks are never edited. No findings →
  `tasks.md` stays untouched and the report says "Converged".
- **`--comment`** (needs a PR and `gh`; only when the user asked for it, never when called by
  another skill): post findings as inline PR review comments. Show the exact comments
  first and post only after the user confirms.

If the same kind of finding keeps appearing across reviews, suggest `/mix-retro` to turn it into
a rule or an automated check.
