---
name: mix-constitution
description: Create or amend the project constitution, the MUST/SHOULD rules agents follow when implementing and reviewing code. Use when the user wants to add, change, or remove a coding rule, or when mix-setup or mix-retro needs to write rules.
argument-hint: "[rule to add or change]"
---

# Constitution

Maintain the project's constitution: the single source of truth for the rules agents follow.
It lives at `mix-dev-skills/constitution.md` under the project's base (resolved by the `mix-scope`
skill). A Spec Kit or other legacy constitution is not edited here: recommend `/mix-migrate`.

## Scope guard

This skill writes the constitution and nothing else. Split the user input into rule content and
other intents (build this, refactor that). Other intents are listed under **Next actions** at the
end with the skill that handles them, never executed here.

## Steps

1. **Load.** Read the existing constitution, or start from `mix-dev-skills/templates/constitution.md` when the project has one, else
   [constitution-template.md](constitution-template.md).
   Read the architecture docs if they exist: it supplies the manifest files, package manager,
   and quality-gate commands for the placeholders.

2. **Shape each rule.** For every rule the user gave (or mix-setup / mix-retro passed in):
   - Decide where it belongs: an existing principle (extend it), a new principle, Quality Gates,
     or Project-Specific Rules. Prefer extending an existing principle over adding a new one.
   - Write it as a checkable statement with `MUST` or `SHOULD`. A reviewer reading only the diff
     must be able to tell pass from fail. Replace vague words ("clean", "robust", "good") with the
     observable behaviour.
   - Phrase the target behaviour positively ("comments are one line") and add the prohibition only
     as a paired guardrail.
   - If a rule is **mechanical** (a banned import, a file-location rule, a syntax pattern), say so
     and propose a lint rule or CI check as well; a deterministic check beats a written rule.
   - If a rule conflicts with an existing one, ask the user which wins before writing.

3. **Fill placeholders.** Every `[ALL_CAPS]` token gets concrete text, or is removed when the
   project has nothing for it (remove `[ADDITIONAL_PRINCIPLES]` when empty). Unknown dates become
   `TODO(RATIFICATION_DATE)`. `LAST_AMENDED_DATE` is today (ISO `YYYY-MM-DD`) when anything changed.

4. **Version.** Bump `CONSTITUTION_VERSION` semantically: MAJOR when a principle is removed or
   redefined, MINOR when one is added or materially expanded, PATCH for wording. New files start
   at `1.0.0`. State the bump reason.

5. **Show the diff, then write.** Present the changed rules to the user and wait for approval.
   Write to `mix-dev-skills/constitution.md`.

6. **Report.** New version and why; any `TODO(...)` left; proposed automated checks; suggested
   commit message (`docs: amend constitution to vX.Y.Z (<summary>)`); **Next actions** if any.

Done when every placeholder is resolved or justified, every rule is checkable, and the user has
approved the written file.
