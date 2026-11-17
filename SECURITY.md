# Security Policy

mix-dev-skills is a set of instructions that an AI agent runs with access to your code, your
shell and, through `mix-pr`, your remotes. A flaw here can make an agent do something you did not
ask for, so security reports are taken seriously.

## Supported versions

Only the latest release on the `main` branch receives fixes. The plugin updates itself; if you
installed with `install.sh`, run it again to update.

## What counts as a vulnerability

- A skill that pushes, opens a PR, comments, writes to a tracker or deletes data without the user
  asking for it.
- A skill that can be steered by untrusted content (an issue, a PR comment, a web page, a file in
  the repo) into running commands or changing files: prompt injection.
- A skill or script that sends code, secrets or personal data anywhere the user did not choose.
- Unsafe shell in `install.sh` or `skills/*/scripts/` (for example, unquoted paths that can delete
  the wrong folder).

Wrong output, a missed step or a poor review are bugs, not vulnerabilities: open a normal issue
for those.

## Reporting

Report privately, never in a public issue:

1. Preferably through **GitHub private vulnerability reporting**: the *Security* tab →
   *Report a vulnerability*.
2. Or by email to **bruno.dias.donnici@gmail.com** with the subject `[mix-dev-skills security]`.

Include the skill, the agent and version, the steps or the malicious input, and what happened.

## What to expect

- Acknowledgement within 3 business days.
- An assessment and a plan within 10 business days.
- Credit in the release notes once a fix ships, unless you prefer to stay anonymous.

Please give the fix a chance to ship before disclosing details publicly.
