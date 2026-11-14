---
name: mix-spike
description: "Answer an open technical question before anything is specified: map how the system handles it today across repos, run a throwaway proof of concept, compare options, and write spike.md with a phased recommendation. Use when the user asks for a spike, an investigation, a feasibility study, or how to integrate or automate something unknown, or when a ticket is a research task."
argument-hint: "<question | ticket key>"
---

# Spike

A spike buys knowledge, not code. It ends in a `spike.md` a person can decide from, and in
nothing merged: proofs of concept stay throwaway.

**Context**: call the Skill tool with `mix-scope` to resolve the project: its repos, the
tracker, the knowledge notes, the architecture docs, and the specs folder. A git repo is not
required.

## Redact

Captured requests, cookies, tokens, and personal or financial data are written as `<REDACTED>`
in every output and file. Proofs of concept read credentials from the environment.

## 1. Frame the question

From the argument (a ticket is read through the configured tracker, read-only), write the
question in one sentence, what decision it feeds, and the time box. Ask the user only when the
question has two plausible readings; give your recommended reading first.

Create `specs/<NNN-short-name>/spike.md` under the project's base from
`mix-dev-skills/templates/spike.md` when the project has one, else
[spike-template.md](spike-template.md), numbered like specs. In a hub, follow its file
conventions (list the spike in the specs index when the hub keeps one).

**Done when** **Question**, **Time box**, and **Context** are filled.

## 2. Map the current state

Read the knowledge notes related to the question (index first), then the code in every repo
that touches the area (one read-only subagent per repo when there are several): data model,
flows, the existing handling of similar cases, and what the other repos expect.

**Done when** **Current State** cites files in each relevant repo.

## 3. Prove it

Build the smallest proof of concept that answers the riskiest unknown: a script against the
real endpoint, a captured flow replayed, a spike branch exercising one call. Keep it outside the
code repos' tracked files (a scratch folder in the spike directory, or a throwaway branch the
user approved). Run it and record the output. A blocker (captcha, WAF, missing access, rate
limit) is a finding: record what was tried and where it stopped.

**Done when** **Findings** has the run command, its redacted output, and every blocker hit.

## 4. Options and recommendation

List two to four options, each with effort, risks, and prerequisites, grounded in the findings.
Recommend one, with a phased path when the best option is blocked today (a manual step now, the
automation once its blocker is removed). Material decisions that are the user's go through the
Skill tool with `mix-grill`.

**Done when** **Options**, **Recommendation**, and **Open Questions** are filled and every
recommendation line traces to a finding.

## 5. Report

The spike path, the question, the recommendation in two sentences, blockers found, the proof of
concept's location, and the next step: `/mix-specify --quick` from this spike when the
recommendation needs building, else none. Delete scratch files the user does not want kept,
after asking.
