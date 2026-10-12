---
name: mix-analyze
description: "Read-only consistency check across spec.md, plan.md, and tasks.md before implementing: coverage gaps, contradictions, ambiguity, constitution violations, and missing reuse. Spec Kit's analyze, extended."
disable-model-invocation: true
argument-hint: "[feature dir]"
---

# Analyze

Find what would make implementation go wrong, before it starts. **Strictly read-only**: this skill
writes no files. It ends by offering remediation edits, which happen only if the user approves.

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos (one or
several) and the paths to the constitution, architecture docs, glossary, ADRs, and specs folder.
A git repo is not required.

**Feature**: the folder in the project's `specs/` passed as argument; else the one whose spec
**Delivery** line names the current git branch; else the most recently modified one. Requires `spec.md`, `plan.md`, and
`tasks.md`; if one is missing, name the skill that creates it.

## 1. Build inventories

Internally, without echoing the artifacts:

- **Requirements**: every `FR-###`, buildable `SC-###` (skip post-launch business KPIs), and
  acceptance scenario (`US1/AC2`).
- **Tasks**: ID, phase, story, files, exemplar, blockers.
- **Rules**: every MUST/SHOULD in the constitution.
- **Design**: modules, files, seams, and decisions from the plan.

## 2. Detection passes

Report the highest-signal findings, 50 at most (summarise the overflow).

- **Coverage**: requirements with no task; tasks with no requirement; acceptance scenarios with no
  test at an agreed seam; plan files no task creates.
- **Constitution**: plan or tasks conflicting with a MUST (always CRITICAL); new dependencies
  without justification; tasks creating something the Prior Art table says already exists;
  tasks missing an exemplar where the plan names one.
- **Contracts** (multi-repo): an operation consumed but not provided, or provided but unused;
  contract fields without types or constraints; provider and consumer tasks that don't both
  reference the contract; a story crossing repos with no integration task; tasks in a repo the
  plan's **Repos Affected** doesn't list.
- **Tests**: test tasks at seams the plan did not agree; the same behaviour tested at several
  levels; test-per-file patterns.
- **Ambiguity**: vague adjectives without a measure; leftover placeholders and TODOs.
- **Inconsistency**: terminology drift (vs the glossary and across files); entities in the plan
  absent from the spec or vice versa; conflicting decisions; task order contradicting blockers.
- **Duplication**: near-duplicate requirements or tasks.
- **Scope**: tasks or plan elements the spec does not ask for.

Severity: **CRITICAL** = constitution MUST violation, or a P1 requirement with no coverage;
**HIGH** = conflicting or untestable requirement, missing reuse that duplicates existing code;
**MEDIUM** = terminology drift, missing non-functional coverage, redundant test tasks;
**LOW** = wording and minor redundancy.

## 3. Report

```markdown
## Analysis: [feature]

| ID | Category | Severity | Location | Finding | Recommendation |
|----|----------|----------|----------|---------|----------------|

**Coverage**: | Requirement | Tasks | Test seam | Notes |

**Metrics**: requirements, tasks, coverage %, critical / high / medium / low counts
```

Stable IDs (category initial + number) so a rerun on unchanged files gives the same report.
Cite specific lines; report missing sections as missing rather than inventing them.

## 4. Next actions

CRITICAL present → resolve before `/mix-implement`, naming which skill fixes each
(`/mix-specify`, `/mix-plan`, `/mix-tasks`, or a direct edit). Otherwise the user may proceed.
Then ask: "Want concrete remediation edits for the top N findings?" Apply nothing unasked.
