---
name: mix-review
description: Review a PR, branch, or working diff on three axes (Standards against the constitution and repo patterns, Spec against the feature spec, Tests for redundancy and coupling), verify each finding, then fix, append convergence tasks, or post PR comments. Use when the user asks to review code, a PR, or changes since a point, or when mix-implement self-reviews.
argument-hint: "[PR number | branch | ref] [--fix | --tasks | --comment | --report]"
---

# Review

Review a diff on three separate axes, each in its own subagent so one axis can't mask another:

- **Standards**: does the code follow the constitution, the architecture doc, and the repo's
  existing patterns, and is it free of the AI smells in [AI-SMELLS.md](AI-SMELLS.md)?
- **Spec**: does it implement what the spec and tasks asked, no less and no more?
- **Tests**: does each test earn its place?

With `--report`, follow [Report-only mode](#report-only-mode) as well: its rules override the steps
below wherever they differ.

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
  `tasks.md` and `state.yml` stay untouched and the report says "Converged". With tasks appended,
  write `state.yml` in the feature folder, next to `spec.md`, creating it when missing:

  ```yaml
  status: Implementing
  next_step: /mix-implement
  ```

  When the file exists, change only these two values and keep every other key (such as `prs`) and
  comment. Name `/mix-implement` as the next step. Done when `state.yml` holds these values.
- **`--comment`** (needs a PR and `gh`; only when the user asked for it, never when called by
  another skill): post findings as inline PR review comments. Show the exact comments
  first and post only after the user confirms.

If the same kind of finding keeps appearing across reviews, suggest `/mix-retro` to turn it into
a rule or an automated check.

## Report-only mode

`--report` runs inside a read-only run started by another program: nobody answers, and every write
is refused. It covers steps 1 to 5 and replaces step 6.

- **Ask nothing.** Wherever a step would ask, take the path it gives for no answer. No spec found →
  skip the Spec axis and say so in the report.
- **Change nothing.** Edit no file, including `tasks.md` and `state.yml`, and run no git command that
  writes. Publish nothing, and ignore `--fix`, `--tasks` and `--comment`.
- **Read the context folder instead of `gh`.** The prompt names a folder holding `pr.json` (the PR's
  metadata) and `pr.diff` (its diff; files with no patch are listed by name). Pin the diff from
  them and use no `gh` command and no network. Read a full file with `git show <sha>:<path>`, using
  the head sha from `pr.json`; when that fails, review from `pr.diff` alone and say so in the report.
  Run git from the working directory, with the verb right after `git`: `cd` first, `-C` or any other
  option before the verb is refused.
- **Without subagents or `mix-scope`**, run the axes one after another. Take `mix-dev-skills/` and
  `specs/` from the project folder when the prompt names one (a hub project keeps them in the hub),
  otherwise from the working directory. A source that is missing is skipped and named in the report.

End the answer with the findings block, as the last thing in the text, after the step 5 report. Write
one object per finding that survived step 4, in step 4's order of severity, and `[]` when there are
none:

````text
```mix-review-findings
[{ "path": "src/a.ts", "line": 12, "side": "RIGHT", "severity": "blocking", "text": "What is wrong and why.", "fix": "What to change." }]
```
````

- `path`: the file, relative to the repo root. Required.
- `line` and `side`: the line in the diff, with `RIGHT` for the new version and `LEFT` for the old.
  Omit both for a finding on no single line.
- `severity`: `blocking`, `should_fix` or `nit`. Required.
- `text` and `fix`: the finding and the proposed correction. Both required.

Done when the last thing in the answer is a block of valid JSON, and no file and nothing on the PR
changed during the run.
