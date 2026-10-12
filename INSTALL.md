# Installing mix-dev-skills (instructions for agents)

You are installing the `mix-*` skills for the user. Follow these steps.

1. **Ask the scope** unless the user already said it:
   - **User** (default): available in every project → `~/.claude/skills`.
   - **Project**: only the current repository → `./.claude/skills` (committed with the repo).
   - **Another agent**: its skills folder (e.g. `~/.codex/skills`, `./.agents/skills`).

2. **Get the files** into a fresh temporary folder:

   ```bash
   tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/Donnici/mix-dev-skills "$tmp/mix-dev-skills"
   ```

   Without git, download `https://github.com/Donnici/mix-dev-skills/archive/refs/heads/main.tar.gz`
   and extract it into the temporary folder.

3. **Install**, choosing the flag for the scope:

   ```bash
   "$tmp/mix-dev-skills/install.sh"                 # user
   "$tmp/mix-dev-skills/install.sh" --project       # project (run from the repo root)
   "$tmp/mix-dev-skills/install.sh" --target <dir>  # another agent
   ```

   Existing `mix-*` skills in the destination are replaced (that is the update path).

4. **Verify**: every folder under `skills/` in the clone now exists in the destination with its
   `SKILL.md`.

5. **Tell the user** to start a new session (skills load at startup) and run `/mix-setup` in each
   repository, then `/mix-flow` for an overview.

To uninstall, run `install.sh --uninstall` with the same scope flag.
