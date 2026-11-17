# Contributing to mix-dev-skills

Thanks for helping. Contributions in English or Portuguese are welcome.

## Ways to help

- **Report a bug**: a skill that skipped a step, wrote to the wrong place, pushed without being
  asked, or broke on a repo layout. Use the *Bug report* template and include the command you
  ran, the agent and version, and the relevant part of the transcript.
- **Propose a skill or a change**: use the *Skill proposal* template. Explain the problem first;
  the skill comes second.
- **Share a real run**: an issue showing a spec, plan and PR produced by the flow (with private
  code removed) helps more than a feature request.
- **Fix docs**: typos, unclear steps, and keeping `README.md` and `README.pt-BR.md` in sync.

## Repository layout

```text
skills/mix-*/SKILL.md        one folder per skill, plus the templates it links to
.claude-plugin/              Claude Code plugin and marketplace manifests
install.sh, INSTALL.md       manual install for any agent
README.md, README.pt-BR.md   user docs (English and Portuguese)
CREDITS.md                   licenses of the projects this one adapts
```

## Rules for skills

These rules keep every skill usable on its own and predictable for the user. `CLAUDE.md` has the
full list.

1. **Self-contained**: a skill links only to files inside its own folder. Reuse another skill
   through the Skill tool, never through a relative path.
2. **Nothing reaches a remote without the user**: only `mix-pr` pushes or opens PRs, and only
   when the user asked in their own words.
3. **Git is optional**: anything that touches git or `gh` has a path for folders without git.
4. **One repo or many**: tasks and findings always name their repo.
5. **Prose style**: English, imperative, positive phrasing; every step ends on a checkable
   criterion.
6. **New skill or rename**: update the tables in both READMEs and in `skills/mix-flow/SKILL.md`.
7. **Adapted text**: if you adapt text from another project, check that its license allows it,
   add its notice to `CREDITS.md` and name it in the "Where each part came from" table.

## Making a change

1. Fork the repo and create a branch: `feat/<slug>`, `fix/<slug>` or `docs/<slug>`.
2. Install your copy locally and try the change in a real session:

   ```bash
   ./install.sh --project     # from the root of a test repository
   ```

3. Run the skill you changed at least once, end to end, and note what you tested in the PR.
4. Use [Conventional Commits](https://www.conventionalcommits.org/): `feat(mix-review): ...`,
   `fix: ...`, `docs: ...`.
5. If the change is user-facing, bump `version` in `.claude-plugin/plugin.json` (minor for a new
   skill or option, patch for a fix).
6. Open the pull request and fill in the template.

## Review

The maintainer reviews pull requests on a best-effort basis, usually within a week. A PR that
changes behaviour without a tested run, or that adds a skill without a clear problem behind it,
will get questions before it is merged.

By contributing you agree that your work is released under the [MIT License](LICENSE) and that
you follow the [Code of Conduct](CODE_OF_CONDUCT.md).
