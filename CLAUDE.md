# mix-dev-skills

Agent skills, one folder per skill under `skills/mix-*/` (`SKILL.md` + templates it links to).

- Each skill must work when copied alone: link only to files inside its own folder; cross-skill
  reuse goes through the Skill tool (`mix-grill`, `mix-testing`, `mix-review`, `mix-pr`,
  `mix-constitution`, `mix-scope` are model-invoked for that reason).
- Context (project, repos, doc paths) is resolved only by `mix-scope`; other skills call it
  instead of hardcoding paths. Config shape: `skills/mix-setup/config-template.yml`.
- Every skill handles one repo and several (web/bff/api); tasks and findings name their repo.
- Nothing reaches a remote without an explicit user request: only `mix-pr` pushes or opens PRs,
  and only when the user asked in their own words.
- Git is optional in every skill; anything touching git/gh has a no-git path.
- Skill prose: English, imperative, positive phrasing, every step ends on a checkable criterion.
  User docs (`README.md`): Portuguese.
- New skills or renames: update the tables in `README.md` and `skills/mix-flow/SKILL.md`.
