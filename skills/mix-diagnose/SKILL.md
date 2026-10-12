---
name: mix-diagnose
description: Diagnosis loop for hard bugs and performance regressions, across one repo or several. Use when the user says "diagnose" or "debug this", or reports something broken, throwing, failing, flaky, or slow.
argument-hint: "<symptom, error, or issue reference>"
---

# Diagnose

A discipline for hard bugs. Skip a phase only with a stated reason.

**Context**: call the Skill tool with `mix-scope` for the project: its repos and their roles, the
constitution, architecture docs, glossary, ADRs, and knowledge notes (incident write-ups and
setup quirks there often name the cause). In multi-repo projects, locate the symptom first
(which repo shows it) and keep the contract between repos in view: many cross-repo bugs are a
field, status, or auth mismatch at the seam.

## Redact

This skill shows commands, outputs, and captured artifacts. **Redact every secret first**: write
`<REDACTED>` in its place. Build loops against env vars so credentials stay in the environment.
Captured artifacts carry auth headers: quote only the lines that carry the signal. If redacted
output isn't enough to diagnose, say so and ask.

## Phase 1: Build a feedback loop

**This is the skill.** With a **tight** pass/fail signal that goes red on _this_ bug, you will
find the cause; bisection, hypotheses, and instrumentation all just consume it. Without one, no
amount of reading code will save you. Spend disproportionate effort here. **Be aggressive, be
creative, refuse to give up.**

Ways to build one, roughly in this order:

1. **Failing test** at whatever seam reaches the bug: unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server (multi-repo: hit the provider directly to
   split "provider wrong" from "consumer wrong").
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) asserting on DOM, console, or network.
5. **Replay a captured trace**: a saved request, payload, or event log replayed through the path.
6. **Throwaway harness**: a minimal subset of the system (one service, mocked deps) that runs the
   bug path with one call.
7. **Property / fuzz loop**: for "sometimes wrong", run 1000 random inputs.
8. **Bisection harness**: the bug appeared between two known states → automate "boot at X, check"
   so `git bisect run` can drive it.
9. **Differential loop**: same input through old vs new version (or two configs), diff outputs.
10. **Human-in-the-loop script**, last resort: when a person must click, drive them with
    [scripts/hitl-loop.template.sh](scripts/hitl-loop.template.sh) so the loop stays structured.

**Tighten it.** Faster (cache setup, narrow scope), sharper (assert the specific symptom, not
"didn't crash"), more deterministic (pin time, seed randomness, isolate filesystem and network).
A 30-second flaky loop is barely better than none; a 2-second deterministic one is tight.

**Non-deterministic bugs**: aim for a higher reproduction rate, not a clean repro. Loop the
trigger 100×, parallelise, add stress, narrow timing windows. 50% is debuggable; 1% isn't yet.

**No loop possible**: stop and say so, listing what you tried. Ask for access to an environment
that reproduces it, a redacted captured artifact (HAR, logs, recording with timestamps), or
permission to add temporary instrumentation. Do not hypothesise without a loop.

**Done when** you can name **one command**, already run at least once (show it and its redacted
output), that is:

- [ ] **Red-capable**: drives the real bug path and asserts the **user's exact symptom**.
- [ ] **Deterministic**: same verdict every run (or a pinned, high rate for flaky bugs).
- [ ] **Fast**: seconds, not minutes.
- [ ] **Agent-runnable**: unattended, or human-driven only through the HITL script.

Reading code to build a theory before this command exists is the exact failure this skill
prevents: stop and go back to the loop.

## Phase 2: Reproduce and minimise

Run the loop and watch it go red. Confirm it is the failure the **user** described (wrong bug =
wrong fix), that it reproduces across runs, and capture the exact symptom for later checks.

Then shrink to the **smallest scenario that still goes red**: cut inputs, callers, config, data,
steps, and repos one at a time, re-running after each cut. Done when every remaining element is
load-bearing.

## Phase 3: Hypothesise

Write **3–5 ranked, falsifiable hypotheses** before testing any: "If X is the cause, then
changing Y makes the bug disappear / changing Z makes it worse." A hypothesis without a
prediction is a vibe: sharpen or drop it.

**Show the ranked list to the user** before testing: they often re-rank instantly ("we deployed a
change to #3 yesterday"). Don't block on it if they're away.

## Phase 4: Instrument

Each probe maps to one prediction. **One variable at a time.** Prefer a debugger or REPL; then
targeted logs at the boundaries that separate hypotheses; never "log everything and grep".
**Tag every debug log** with a unique prefix (`[DEBUG-a4f2]`) so cleanup is one grep.

**Performance regressions**: logs are usually the wrong tool. Take a baseline measurement
(timing harness, profiler, query plan), then bisect. Measure first, fix second.

## Phase 5: Fix and regression test

Write the regression test **before** the fix, at a **correct seam**: one where the test exercises
the real bug pattern as it happens at the call site (see the `mix-testing` skill). A seam too
shallow to replicate the chain that triggered the bug gives false confidence. **If no correct
seam exists, that is a finding**: record it for the report.

With a correct seam:

1. Turn the minimised repro into a failing test there; watch it fail. If you forced red by
   mutating code or fixtures, diff against a pristine copy to prove the mutation landed.
2. Apply the smallest fix that addresses the confirmed cause, following the constitution and the
   repo's patterns. Cross-repo cause → fix it on the side the contract says is wrong; a contract
   that itself is wrong is a decision for the user.
3. Watch the test pass, then re-run the Phase 1 loop against the original, un-minimised scenario.

## Phase 6: Clean up and report

- [ ] Original repro no longer reproduces (Phase 1 loop re-run).
- [ ] Regression test passes, or the missing seam is documented.
- [ ] Every `[DEBUG-...]` line removed (grep the prefix).
- [ ] Throwaway harnesses deleted or moved to a clearly marked debug location.

Report the confirmed hypothesis, the fix, and the test. Propose a commit message that states the
cause, so the next debugger learns; commit only when the user approves, and push or open a PR
only when they ask (through `mix-pr`). When the finding is "no good seam exists" or the bug came
from a missing check or rule, suggest `/mix-retro` to change the environment so it can't recur.
